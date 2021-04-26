import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'controller_errors.dart';
import 'kelly_can_data.dart';

const _wheelDiameter = 0.33; // m // TODO: Check value!

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

  int get speed {
    final rpm = _canData.rpm;
    return (rpm * (24/112) * _wheelDiameter * pi * 60 / 1000).round();
  }

  double get batteryLevel {
    final _difference = _voltageWhenCharged - _voltageWhenLow;
    final level = (batteryVoltage - _voltageWhenLow) / _difference;
    if (level < 0.0) return 0.0;
    if (level > 1.0) return 1.0;
    return level;
  }

  double get motorCurrent => _canData.motorCurrent;
  double get batteryVoltage => _canData.batteryVoltage;
  int get throttleSignal => _canData.throttleSignal;
  int get controllerTemperature => _canData.controllerTemperature;
  int get motorTemperature => _canData.motorTemperature;
  MotorState get motorStateCommand => _canData.motorStateCommand;
  MotorState get motorStateFeedback => _canData.motorStateFeedback;

  void _runTimer() {
    Timer.periodic(_updateFrequenz, (_) {
      _canData.update();
      _canData.update();
      notifyListeners();
    });
  }
}
