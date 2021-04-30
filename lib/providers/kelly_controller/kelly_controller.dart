import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kart_project/interfaces/gpio_interface.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'controller_errors.dart';
import 'kelly_can_data.dart';

const _wheelDiameter = 0.33; // m

const _voltageWhenCharged = 58.8;
const _voltageWhenLow = 39.2;

enum MotorState {
  neutral,
  forward,
  backward,
}

const _updateFrequenz = const Duration(milliseconds: 50);

class KellyController extends ChangeNotifier {
  KellyController(this._notifications) {
    _runTimer();
  }

  late final _canData = KellyCanData(this);
  NotificationsProvider _notifications;
  ControllerError? _error;

  final _powerGpio = GpioInterface.kellyOff;
  final _enableMotorGpio = GpioInterface.enableMotor;
  final _lowSpeedModeGpio = GpioInterface.lowSpeedMode;

  int get speed {
    final rpm = _canData.rpm;
    return (rpm * (24 / 112) * _wheelDiameter * pi * 60 / 1000).round();
  }

  double get batteryLevel {
    final _difference = _voltageWhenCharged - _voltageWhenLow;
    final level = (batteryVoltage - _voltageWhenLow) / _difference;
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
  bool get isOn => _powerGpio.getValue();
  bool get motorEnabled => _enableMotorGpio.getValue();
  bool get ecoModusActive => _lowSpeedModeGpio.getValue();

  ControllerError? get error => _error;
  set error(ControllerError? controllerError) {
    if (_error != controllerError) {
      if (controllerError == null) {
        if (error != null) _notifications.error.close(_error!.id);
      } else {
        _notifications.error.create(controllerError);
      }
      _error = controllerError;
    }
  }

  void setPower(bool on) {
    _powerGpio.setValue(on);
    notifyListeners();
  }

  void enableMotor(bool locked) {
    _enableMotorGpio.setValue(locked);
    notifyListeners();
  }

  void setLowSpeedMode(bool active) {
    _lowSpeedModeGpio.setValue(active);
    notifyListeners();
  }

  void _runTimer() {
    Timer.periodic(_updateFrequenz, (_) {
      // _canData.update();
      // _canData.update();
      // notifyListeners();
    });
  }

  Future restart() async {
    setPower(false);
    await Future.delayed(Duration(seconds: 3), () {
      setPower(true);
    });
  }
}
