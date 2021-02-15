import 'dart:async';
import 'package:flutter_gpiod/flutter_gpiod.dart';

/// Enables you to use software PWM on the given pin.
///
/// Use WiringPi Software PWM instead.
@deprecated
class PwmGpioLine {
  GpioLine _gpio;
  double _ratio = 0.5;
  bool _active = false;

  /// Duration of one period in milliseconds.
  int periodDuration;

  PwmGpioLine(this._gpio, {this.periodDuration: 20});

  /// The percentage on how long the pin is set to true inside of a period.
  double get ratio => _ratio;

  /// Sets the ratio of the period.
  set ratio(double ratio) {
    if (ratio > 1.0 || ratio < 0.0) {
      throw ArgumentError("Ratio must be between 0 and 1.");
    }
    _ratio = ratio;
    _runClock();
  }

  /// Calcs the delay with the ratio and frequence and rounds it to an integer.
  int _calcDelay(double ratio) => (ratio * periodDuration).round();

  /// Runs the pwm clock and sets [_active] to true.
  Future _runClock() async {
    _active = true;
    while (_active) {
      if (_ratio != 0.0) {
        _gpio.setValue(true);
        await Future.delayed(Duration(milliseconds: _calcDelay(ratio)));
      }
      if (_ratio != 1.0) {
        _gpio.setValue(false);
        await Future.delayed(Duration(milliseconds: _calcDelay(1 - ratio)));
      }
    }
  }
}
