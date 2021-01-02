import 'package:flutter_gpiod/flutter_gpiod.dart';

/// Label of the default RaspberryPi GPIO chip.
const String _gpioChip = 'pinctrl-bcm2835';
const String _gpioConsumer = 'KartProject_PWM';

/// Enables you to use software PWM on the given pin.
class PwmInterface {
  /// Acess to the GPIO pin.
  GpioLine _line;

  /// Set to true if clock is running.
  bool _active = false;

  /// The percentage on how long the pin is set to true inside of a period.
  double _ratio = 0.5;

  /// Duration of one period in milliseconds. Default is 5.
  int periodDuration;

  PwmInterface(int pin, {this.periodDuration: 5}) {
    final gpioChips = FlutterGpiod.instance.chips;
    final chip = gpioChips.singleWhere((c) => c.label == _gpioChip);
    _line = chip.lines[pin];
    _line.requestOutput(consumer: _gpioConsumer, initialValue: false);
  }

  /// Sets the ratio of the period.
  void setPwmRatio(double newRatio) {
    if (newRatio > 1.0 || newRatio < 0.0) {
      throw ArgumentError("Ratio must be between 0 and 1.");
    }
    _ratio = newRatio;
    if (!_active) _runClock();
  }

  /// Calcs the delay with the ratio and frequence and rounds it to and integer.
  int _calcDelay(double ratio) => (ratio * periodDuration).round();

  /// Runs the pwm clock and sets [_active] to true.
  Future _runClock() async {
    _active = true;
    while (_active) {
      if (_ratio != 0.0) {
        _line.setValue(true);
        await Future.delayed(
          Duration(milliseconds: _calcDelay(_ratio)),
        );
      }
      if (_ratio != 1.0) {
        _line.setValue(false);
        await Future.delayed(
          Duration(milliseconds: _calcDelay(1 - _ratio)),
        );
      }
    }
  }
}
