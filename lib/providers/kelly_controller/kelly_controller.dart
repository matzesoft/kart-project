import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kart_project/interfaces/gpio_interface.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/providers/profil_provider.dart';
import 'controller_errors.dart';
import 'kelly_can_data.dart';

const _WHEEL_DIAMETER = 0.33; // m

const _VOLTAGE_WHEN_CHARGED = 58.8;
const _VOLTAGE_WHEN_LOW = 39.2;

const _ENABLE_MOTOR_THROTTLE_LIMIT = 0.05;

enum MotorState {
  neutral,
  forward,
  backward,
}

const _UPDATE_FREQUENZ = const Duration(milliseconds: 50);

class KellyController extends ChangeNotifier {
  KellyController(this._profil, this._notifications) {
    _canData = KellyCanData(this);
    _canData.setup().then((_) => _runTimer());
  }

  KellyController update(Profil newProfil) {
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

  final KellyController _controller;
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
