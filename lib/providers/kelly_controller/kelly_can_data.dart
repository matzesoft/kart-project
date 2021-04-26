import 'dart:io';
import 'package:linux_can/linux_can.dart';
import 'kelly_controller.dart';
import 'controller_errors.dart' as controllerErrors;

/// First Message of Kelly CAN protocol
const _canMessage1 = 0x8CF11E05;

const _rpmLSBIndex = 0;
const _rpmMSBIndex = 1;
const _rpmRange = 6000;

const _motorCurrentLSBIndex = 2;
const _motorCurrentMSBIndex = 3;
const _motorCurrentRange = 4000;
const _motorCurrentDivider = 10;

const _batteryVoltageLSBIndex = 4;
const _batteryVoltageMSBIndex = 5;
const _batteryVoltageRange = 1800;
const _batteryVoltageDivider = 10;

const _errorLSBIndex = 6;
const _errorMSBIndex = 7;
final _errors = {
  0x0001: controllerErrors.identificationError, //ERR0
  0x0002: controllerErrors.overVoltage, //ERR1
  0x0004: controllerErrors.lowVoltage, //ERR2
  0x0010: controllerErrors.stallError, //ERR4
  0x0020: controllerErrors.generalControllerError, //ERR5
  0x0040: controllerErrors.controllerOverTemperature, //ERR6
  0x0080: controllerErrors.throttleError, //ERR7
  0x0200: controllerErrors.generalControllerError, //ERR9
  0x0400: controllerErrors.throttleError, //ERR10
  0x0800: controllerErrors.generalControllerError, //ERR11
  0x4000: controllerErrors.motorOverTemperature, //ERR14
  0x8000: controllerErrors.generalControllerError, //ERR15
};

// Second Message of Kelly CAN protocol
const _canMessage2 = 0x8CF11F05;

const _throttleSignalIndex = 0;
const _throttleSignalRange = 255;

const _controllerTemperatureIndex = 1;
const _controllerTemperatureOffset = 40;

const _motorTemperatureIndex = 2;
const _motorTemperatureOffset = 30;

const _statusOfControllerIndex = 4;
const _statusOfCommandsBits = 0x03;
const _statusOfFeedbackBits = 0x0C;
const _statusOfFeedbackOffset = 2;
const _statusOfControllerStates = [
  MotorState.neutral,
  MotorState.forward,
  MotorState.backward,
];
// const _statusOfSwitchSignalsIndex = 5;

const _canModulBitrate = 250000;

class KellyCanData {
  final KellyController _controller;
  final _can = CanDevice(bitrate: _canModulBitrate);
  int _failedReads = 0;

  int _rpm = 0;
  double _motorCurrent = 0;
  double _batterVoltage = 0;
  int _throttleSignal = 0;
  int _controllerTemperature = 25;
  int _motorTemperature = 25;
  MotorState _motorStateCommand = MotorState.neutral;
  MotorState _motorStateFeedback = MotorState.neutral;

  int get rpm => _rpm;
  double get motorCurrent => _motorCurrent;
  double get batteryVoltage => _batterVoltage;
  int get throttleSignal => _throttleSignal;
  int get controllerTemperature => _controllerTemperature;
  int get motorTemperature => _motorTemperature;
  MotorState get motorStateCommand => _motorStateCommand;
  MotorState get motorStateFeedback => _motorStateFeedback;

  KellyCanData(this._controller) {
    try {
      _can.setup();
    } on SocketException {
      _communicationFailed();
    }
  }

  void update() {
    try {
      final frame = _can.read();
      final failedReading = frame.data.isEmpty;

      // Increases [_failedReads] for every empty frame. Resets when one read
      // was sucessful.
      if (failedReading) {
        _failedReads += 1;
        if (_failedReads == 6) {
          throw SocketException("Unable to read from can bus.");
        }
      } else {
        if (_failedReads > 0) _failedReads = 0;
        if (_controller.error == controllerErrors.communicationError)
          _controller.error = null;

        if (frame.id == _canMessage1) _updateFromMsg1(frame);
        if (frame.id == _canMessage2) _updateFromMsg2(frame);
      }
    } on SocketException {
      _communicationFailed();
    }
  }

  void _updateFromMsg1(CanFrame frame) {
    final data = frame.data;

    final rpm = _convertFrom2Bytes(data[_rpmMSBIndex], data[_rpmLSBIndex]);
    if (_inRange(rpm, _rpmRange)) {
      _rpm = rpm;
    }

    final current = _convertFrom2Bytes(
      data[_motorCurrentMSBIndex],
      data[_motorCurrentLSBIndex],
    );
    if (_inRange(current, _motorCurrentRange)) {
      _motorCurrent = current / _motorCurrentDivider;
    }

    final voltage = _convertFrom2Bytes(
      data[_batteryVoltageMSBIndex],
      data[_batteryVoltageLSBIndex],
    );
    if (_inRange(voltage, _batteryVoltageRange)) {
      _batterVoltage = voltage / _batteryVoltageDivider;
    }

    final error = _convertFrom2Bytes(
      data[_errorMSBIndex],
      data[_errorLSBIndex],
    );
    if (error == 0) {
      if (_errors.containsValue(_controller.error)) {
        _controller.error = null;
      }
    } else if (_errors.containsKey(error)) {
      _controller.error = _errors[error]!;
    }
  }

  void _updateFromMsg2(CanFrame frame) {
    final data = frame.data;

    final throttleSignal = data[_throttleSignalIndex];
    if (_inRange(throttleSignal, _throttleSignalRange)) {
      _throttleSignal = throttleSignal;
    }

    final contTemp = data[_controllerTemperatureIndex];
    _controllerTemperature = contTemp - _controllerTemperatureOffset;

    final motTemp = data[_motorTemperatureIndex];
    _motorTemperature = motTemp - _motorTemperatureOffset;

    final _statusCont = data[_statusOfControllerIndex];
    final _statusOfCommand = _statusCont & _statusOfCommandsBits;
    _motorStateCommand = _statusOfControllerStates[_statusOfCommand];

    final _statusOfFeedback =
        (_statusCont & _statusOfFeedbackBits) >> _statusOfFeedbackOffset;
    _motorStateFeedback = _statusOfControllerStates[_statusOfFeedback];
  }

  /// Converts to bytes to one integer.
  int _convertFrom2Bytes(int msb, int lsb) {
    int res = ((msb * 256) + lsb);
    return res;
  }

  bool _inRange(int value, int range) {
    return value >= 0 && value <= range;
  }

  void _communicationFailed() {
    _controller.error = controllerErrors.communicationError;
  }
}
