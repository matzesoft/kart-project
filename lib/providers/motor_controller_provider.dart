import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kart_project/interfaces/gpio_interface.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/providers/profil_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/settings/settings.dart';
import 'package:linux_can/linux_can.dart';

const _WHEEL_DIAMETER = 0.33; // m

const _VOLTAGE_WHEN_CHARGED = 50.4;
const _VOLTAGE_WHEN_LOW = 42.0;

const _ENABLE_MOTOR_THROTTLE_LIMIT = 0.05;

const _MOTOR_CURRENT_MAX = 176.0;

enum MotorState {
  neutral,
  forward,
  backward,
}

const _UPDATE_FREQUENZ = const Duration(milliseconds: 50);

class MotorControllerProvider extends ChangeNotifier {
  MotorControllerProvider(this._profil, this._notifications) {
    _canData = KellyCanData._(this);
    _canData.setup().then((_) => _runTimer());
  }

  MotorControllerProvider update(Profil newProfil) {
    if (_profil != newProfil) {
      _profil = newProfil;
      lowSpeedMode._onProfilSwitched();
      notifyListeners();
    }
    return this;
  }

  late final KellyCanData _canData;
  late final lowSpeedMode = LowSpeedModeController(this);
  final _powerGpio = GpioInterface.kellyOff;
  final _enableMotorGpio = GpioInterface.enableMotor;
  NotificationsProvider _notifications;
  Profil _profil;
  ControllerError? _error;
  Timer? _timer;

  int get speed {
    final rpm = _canData.rpm;
    return (rpm * (24 / 112) * _WHEEL_DIAMETER * pi * 60 / 1000).round();
  }

  double get batteryLevel {
    final _difference = _VOLTAGE_WHEN_CHARGED - _VOLTAGE_WHEN_LOW;
    final level = (batteryVoltage - _VOLTAGE_WHEN_LOW) / _difference;
    if (level < 0.0) return 0.0;
    if (level > 1.0) return 1.0;
    return level;
  }

  double get throttleSignal {
    return _canData.throttleSignal / 0xFF;
  }

  double get motorCurrent => _canData.motorCurrent;
  double get motorCurrentInPercent => motorCurrent / _MOTOR_CURRENT_MAX;
  double get batteryVoltage => _canData.batteryVoltage;

  int get controllerTemperature => _canData.controllerTemperature;
  int get motorTemperature => _canData.motorTemperature;

  MotorState get motorStateCommand => _canData.motorStateCommand;
  MotorState get motorStateFeedback => _canData.motorStateFeedback;

  ControllerError? get error => _error;
  set error(ControllerError? controllerError) {
    if (error != controllerError) {
      if (error != null) _notifications.error.close(_error!.id);
      if (controllerError != null) _notifications.error.create(controllerError);
      _error = controllerError;
    }
  }

  bool get isOn => _powerGpio.getValue();

  void setPower(bool on) {
    if (on) {
      _runTimer();
    } else {
      if (_timer != null) _timer!.cancel();
    }
    _powerGpio.setValue(on);
    notifyListeners();
  }

  bool get motorEnabled => _enableMotorGpio.getValue();

  bool get allowDisEnableMotor {
    if (motorEnabled) {
      if (speed <= 0) return true;
    } else {
      if (throttleSignal <= _ENABLE_MOTOR_THROTTLE_LIMIT) return true;
    }
    return false;
  }

  void enableMotor(bool locked) {
    if (allowDisEnableMotor) {
      _enableMotorGpio.setValue(locked);
      notifyListeners();
    }
  }

  void _runTimer() {
    _timer = Timer.periodic(_UPDATE_FREQUENZ, (_) {
      _canData.update();
      _canData.update();
      lowSpeedMode._onBatteryLevelChange();
      notifyListeners();
    });
  }

  Future restart() async {
    setPower(false);
    await Future.delayed(Duration(seconds: 3), () {
      setPower(true);
    });
  }

  void _notify() {
    notifyListeners();
  }
}

const _FORCE_LOW_SPEED_MODE_LIMIT = 0.20;
const _UNFORCE_LOW_SPEED_MODE_LIMIT = 0.30;

class LowSpeedModeController {
  LowSpeedModeController(this._controller) {
    if (alwaysActive && !isActive) _activateLowSpeedMode(true);
  }

  final MotorControllerProvider _controller;
  double get _batteryLevel => _controller.batteryLevel;

  final _lowSpeedModeGpio = GpioInterface.lowSpeedMode;
  bool _forceLowSpeedMode = false;

  bool get isActive => _lowSpeedModeGpio.getValue();

  /// Returns true if the battery level is under [_FORCE_LOW_SPEED_MODE_LIMIT].
  /// Turns back to false when over [_UNFORCE_LOW_SPEED_MODE_LIMIT].
  bool get forceLowSpeed {
    bool force = false;
    if (!_forceLowSpeedMode) {
      if (_batteryLevel <= _FORCE_LOW_SPEED_MODE_LIMIT) force = true;
    } else {
      if (_batteryLevel <= _UNFORCE_LOW_SPEED_MODE_LIMIT) force = true;
    }
    _forceLowSpeedMode = force;
    return _forceLowSpeedMode;
  }

  bool get alwaysActive => _controller._profil.lowSpeedAlwaysActive;
  set alwaysActive(bool setActive) {
    _controller._profil.lowSpeedAlwaysActive = setActive;
    if (!forceLowSpeed) {
      if (isActive != setActive) _activateLowSpeedMode(setActive);
    }
  }

  void _onBatteryLevelChange() {
    if (!alwaysActive) {
      if (isActive != forceLowSpeed) _activateLowSpeedMode(forceLowSpeed);
    }
  }

  void _onProfilSwitched() {
    if (!forceLowSpeed) {
      if (isActive != alwaysActive) _activateLowSpeedMode(alwaysActive);
    }
  }

  void _activateLowSpeedMode(bool activate) {
    _lowSpeedModeGpio.setValue(activate);
    _controller._notify();
  }
}

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
  0x0001: _identificationError, //ERR0
  0x0002: _overVoltage, //ERR1
  0x0004: _lowVoltage, //ERR2
  0x0010: _stallError, //ERR4
  0x0020: _generalControllerError, //ERR5
  0x0040: _controllerOverTemperature, //ERR6
  0x0080: _throttleError, //ERR7
  0x0200: _generalControllerError, //ERR9
  0x0400: _throttleError, //ERR10
  0x0800: _generalControllerError, //ERR11
  0x4000: _motorOverTemperature, //ERR14
  0x8000: _generalControllerError, //ERR15
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
  final MotorControllerProvider _controller;
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

  KellyCanData._(this._controller);

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
        if (_controller.error == _communicationError) _controller.error = null;

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
    _controller.error = _communicationError;
  }
}

class ControllerError extends ErrorNotification {
  ControllerError(
    String id, {
    required IconData icon,
    required String categorie,
    required String title,
    required String message,
  }) : super(
          id,
          icon: icon,
          categorie: categorie,
          title: title,
          message: message,
          moreDetails: showErrorDetails,
        );

  static showErrorDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      Settings.route,
      arguments: 1, // Drive Options
    );
  }
}

final _generalControllerError = ControllerError(
  'InternalControllerError',
  categorie: Strings.motorErrorCategorie,
  icon: EvaIcons.alertTriangleOutline,
  title: Strings.generalControllerErrorTitle,
  message: Strings.generalControllerErrorMessage,
);

final _communicationError = ControllerError(
  'CommunicationError',
  icon: EvaIcons.shakeOutline,
  categorie: Strings.motorErrorCategorie,
  title: Strings.communicationErrorTitle,
  message: Strings.communicationErrorMessage,
);

final _identificationError = ControllerError(
  'IdentificationError',
  icon: EvaIcons.activity,
  categorie: Strings.motorErrorCategorie,
  title: Strings.identificationErrorTitle,
  message: Strings.identificationErrorMessage,
);

final _overVoltage = ControllerError(
  'OverVoltage',
  icon: EvaIcons.flashOutline,
  categorie: Strings.supplyErrorCategorie,
  title: Strings.overVoltageTitle,
  message: Strings.overVoltageMessage,
);

final _lowVoltage = ControllerError(
  'LowVoltage',
  icon: EvaIcons.flashOffOutline,
  categorie: Strings.supplyErrorCategorie,
  title: Strings.lowVoltageTitle,
  message: Strings.lowVoltageTitle,
);

final _stallError = ControllerError(
  'StallError',
  icon: EvaIcons.navigationOutline,
  categorie: Strings.motorErrorCategorie,
  title: Strings.stallErrorTitle,
  message: Strings.stallErrorMessage,
);

final _controllerOverTemperature = ControllerError(
  'ControllerOverTemperature',
  icon: EvaIcons.thermometerPlusOutline,
  categorie: Strings.motorErrorCategorie,
  title: Strings.controllerOverTemperatureTitle,
  message: Strings.controllerOverTemperatureMessage,
);

final _motorOverTemperature = ControllerError(
  'MotorOverTemperature',
  icon: EvaIcons.thermometerPlusOutline,
  categorie: Strings.heatErrorCategorie,
  title: Strings.motorOverTemperatureTitle,
  message: Strings.motorOverTemperatureMessage,
);

final _throttleError = ControllerError(
  'ThrottleError',
  icon: EvaIcons.logInOutline,
  categorie: Strings.motorErrorCategorie,
  title: Strings.throttleErrorTitle,
  message: Strings.throttleErrorMessage,
);
