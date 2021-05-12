import 'dart:io';
import 'package:linux_can/linux_can.dart';
import 'kelly_controller.dart';
import 'controller_errors.dart' as controllerErrors;

/// First Message of Kelly CAN protocol
const _CAN_MESSAGE1 = 0x8CF11E05;

const _RPM_LSB_INDEX = 0;
const _RPM_MSB_INDEX = 1;
const _RPM_RANGE = 6000;

const _MOTOR_CURRENT_LSB_INDEX = 2;
const _MOTOR_CURRENT_MSB_INDEX = 3;
const _MOTOR_CURRENT_RANGE = 4000;
const _MOTOR_CURRENT_DIVIDER = 10;

const _BATTERY_VOLTAGE_LSB_INDEX = 4;
const _BATTRY_VOLTAGE_MSB_INDEX = 5;
const _BATTERY_VOLTAGE_RANGE = 1800;
const _BATTERY_VOLTAGE_DIVIDER = 10;

const _ERROR_LSB_INDEX = 6;
const _ERROR_MSB_INDEX = 7;
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
const _CAN_MESSAGE2 = 0x8CF11F05;

const _THROTTLE_SIGNAL_INDEX = 0;
const _THROTTLE_SIGNAL_RANGE = 255;

const _CONTROLLER_TEMPERATURE_INDEX = 1;
const _CONTROLLER_TEMPERATURE_OFFSET = 40;

const _MOTOR_TEMPERATURE_INDEX = 2;
const _MOTOR_TEMPERATURE_OFFSET = 30;

const _STAUS_OF_CONTROLLER_INDEX = 4;
const _STATUS_OF_COMMANDS_BITS = 0x03;
const _STATUS_OF_FEEDBACK_BITS = 0x0C;
const _STATUS_OF_FEEDBACK_OFFSET = 2;
const _STATUS_OF_CONTROLLER_STATES = [
  MotorState.neutral,
  MotorState.forward,
  MotorState.backward,
];
// const _statusOfSwitchSignalsIndex = 5;

const _CAN_MODUL_BITRATE = 250000;

// Update frequency: Per 50ms x2 -> Wait 2 seconds
const _FAILED_READS_LIMIT = (20 * 2) * 2;

class KellyCanData {
  final KellyController _controller;
  final _can = CanDevice(bitrate: _CAN_MODUL_BITRATE);
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

  KellyCanData(this._controller);

  Future setup() async {
    try {
      await _can.setup();
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
        if (_failedReads >= _FAILED_READS_LIMIT) {
          throw SocketException("Unable to read from can bus.");
        }
      } else {
        if (_failedReads > 0) _failedReads = 0;
        if (_controller.error == controllerErrors.communicationError)
          _controller.error = null;

        if (frame.id == _CAN_MESSAGE1) _updateFromMsg1(frame);
        if (frame.id == _CAN_MESSAGE2) _updateFromMsg2(frame);
      }
    } on SocketException {
      _communicationFailed();
    }
  }

  void _updateFromMsg1(CanFrame frame) {
    final data = frame.data;

    final rpm = _convertFrom2Bytes(data[_RPM_MSB_INDEX], data[_RPM_LSB_INDEX]);
    if (_inRange(rpm, _RPM_RANGE)) {
      _rpm = rpm;
    }

    final current = _convertFrom2Bytes(
      data[_MOTOR_CURRENT_MSB_INDEX],
      data[_MOTOR_CURRENT_LSB_INDEX],
    );
    if (_inRange(current, _MOTOR_CURRENT_RANGE)) {
      _motorCurrent = current / _MOTOR_CURRENT_DIVIDER;
    }

    final voltage = _convertFrom2Bytes(
      data[_BATTRY_VOLTAGE_MSB_INDEX],
      data[_BATTERY_VOLTAGE_LSB_INDEX],
    );
    if (_inRange(voltage, _BATTERY_VOLTAGE_RANGE)) {
      _batterVoltage = voltage / _BATTERY_VOLTAGE_DIVIDER;
    }

    final error = _convertFrom2Bytes(
      data[_ERROR_MSB_INDEX],
      data[_ERROR_LSB_INDEX],
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

    final throttleSignal = data[_THROTTLE_SIGNAL_INDEX];
    if (_inRange(throttleSignal, _THROTTLE_SIGNAL_RANGE)) {
      _throttleSignal = throttleSignal;
    }

    final contTemp = data[_CONTROLLER_TEMPERATURE_INDEX];
    _controllerTemperature = contTemp - _CONTROLLER_TEMPERATURE_OFFSET;

    final motTemp = data[_MOTOR_TEMPERATURE_INDEX];
    _motorTemperature = motTemp - _MOTOR_TEMPERATURE_OFFSET;

    final _statusCont = data[_STAUS_OF_CONTROLLER_INDEX];
    final _statusOfCommand = _statusCont & _STATUS_OF_COMMANDS_BITS;
    _motorStateCommand = _STATUS_OF_CONTROLLER_STATES[_statusOfCommand];

    final _statusOfFeedback =
        (_statusCont & _STATUS_OF_FEEDBACK_BITS) >> _STATUS_OF_FEEDBACK_OFFSET;
    _motorStateFeedback = _STATUS_OF_CONTROLLER_STATES[_statusOfFeedback];
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
