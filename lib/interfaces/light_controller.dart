import 'dart:async';
import 'dart:math';
import 'package:kart_project/interfaces/gpio_interface.dart';
import 'package:wiring_pi_soft_pwm/wiring_pi_soft_pwm.dart';

/// How long one period takes. Calculated with a frequency of `30Hz`:
/// `1 / 30Hz = 0.03125sek`
const _PERIOD_DURATION = Duration(milliseconds: 31);

/// How much the light brightness changes per period.
const _PERIOD_CHANGE = 0.02;

/// Controller of the front light of the kart.
class LightController {
  SoftPwmPin _pwmPin;
  Timer _timer;

  /// Current brightness of the light.
  double _currentFactor = 0.0;

  /// The light should be animated to when changing the [currentFactor].
  double _endFactor;

  LightController() {
    final _interface = SoftPwmInterface();
    _pwmPin = SoftPwmPin(_interface, FRONT_LIGHT_PIN);
    _pwmPin.setup();
  }

  /// Current brightness of the light.
  double get currentFactor => _currentFactor;

  /// Sets the current factor and updates the output of the pwm GPIO.
  set currentFactor(double factor) {
    _currentFactor = factor;
    _setPwmRatio(_currentFactor);
  }

  void setLight(double factor) {
    if (_timer != null && _timer.isActive) _timer.cancel();
    _endFactor = factor;
    final difference = (_endFactor - _currentFactor);

    _timer = difference.isNegative
        ? Timer.periodic(_PERIOD_DURATION, (_) {
            double newFactor = currentFactor;
            newFactor -= _PERIOD_CHANGE;

            if (newFactor <= _endFactor) {
              currentFactor = _endFactor;
              _timer.cancel();
            } else {
              currentFactor = newFactor;
            }
          })
        : Timer.periodic(_PERIOD_DURATION, (_) {
            double newFactor = currentFactor;
            newFactor += _PERIOD_CHANGE;

            if (newFactor >= _endFactor) {
              currentFactor = _endFactor;
              _timer.cancel();
            } else {
              currentFactor = newFactor;
            }
          });
  }

  /// Because of hardware reasons, the brightness of the lights is changing much
  /// faster in higher ranges. By recalculating the factor with the sine, the
  /// factor fits better to the actual behavior.
  void _setPwmRatio(double factor) {
    factor = sin(factor * (pi / 2));
    final value = (factor * 100).round();
    _pwmPin.write(value);
  }
}
