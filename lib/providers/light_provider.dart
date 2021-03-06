import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/interfaces/gpio_interface.dart';
import 'package:kart_project/providers/boot_provider.dart';
import 'package:kart_project/providers/profil_provider.dart';
import 'package:provider/provider.dart';
import 'package:wiring_pi_soft_pwm/wiring_pi_soft_pwm.dart';

/// Brightness when the [LightState] is set to [LightState.dimmed].
const FRONT_DIMMED_BRIGHTNESS = 0.3;

/// Possible states of the light.
enum LightState {
  off,

  /// Brightness will always be set to [FRONT_DIMMED_BRIGHTNESS].
  dimmed,

  /// Brightness will be set to the [_frontMaxBrightness] saved in the profil.
  on,
}

/// Lets you control the lights of the kart.
class LightProvider extends ChangeNotifier {
  Profil _profil;
  final frontLight = FrontLightController();
  final backLight = BackLightController();
  LightState _lightState = LightState.off;

  /// The maximum brightness the light can be set to.
  double get frontMaxBrightness => _profil.maxLightBrightness;
  set frontMaxBrightness(double maxBrightness) =>
      _profil.maxLightBrightness = maxBrightness;

  LightProvider(BuildContext context) {
    _profil = context.profil();
    _updateLightWithLock(context.locked());
  }

  /// Updates the [LightProvider] with the data of the [newprofil] and the
  /// [locked] value of the [BootProvider]. Returns the back the object itself.
  /// This is normally called inside a [ProxyProvider]s update method.
  /// Does update all listeners.
  LightProvider update(Profil newProfil, bool locked) {
    _ifProfilSwitched(newProfil);
    _profil = newProfil;
    _updateLightWithLock(locked);
    notifyListeners();
    return this;
  }

  /// State of the light. Could be `off`, `dimmed` or `on`.
  LightState get lightState => _lightState;

  /// Updates [lightState] and sets the light brightness based on the setting.
  /// Calls the listeners if notify is true.
  void setLightState(LightState state, {bool notify: true}) {
    _lightState = state;
    if (state == LightState.off) {
      frontLight.setLight(0.0);
      backLight.setLight(false);
    } else {
      backLight.setLight(true);
      state == LightState.dimmed
          ? frontLight.setLight(FRONT_DIMMED_BRIGHTNESS)
          : frontLight.setLight(frontMaxBrightness);
    }
    if (notify) notifyListeners();
  }

  /// Should be called if there is an change to the profil. Checks if the profil
  /// has switched and sets [_lightState] to dimmed if true.
  bool _ifProfilSwitched(Profil newProfil) {
    if (newProfil != _profil) {
      if (_lightState == LightState.on) setLightState(LightState.dimmed);
      return true;
    }
    return false;
  }

  /// Called when there is a change to the lock-state. Sets the [_lightState]
  /// to [LightState.dimmed] if locked. Does not update any listeners.
  void _updateLightWithLock(bool locked) {
    if (locked == true && _lightState == LightState.on)
      setLightState(LightState.dimmed, notify: false);
  }

  /// Should be called when the software wants to shutdown.
  void powerOff() {
    setLightState(LightState.off, notify: false);
  }
}

/// Controls the PWM values of the front light.
class FrontLightController {
  /// How long one period takes. Calculated with a frequency of `30Hz`:
  /// `1 / 30Hz = 0.03125sek`
  static const _PERIOD_DURATION = Duration(milliseconds: 31);

  /// How much the light brightness changes per period.
  static const _PERIOD_CHANGE = 0.02;

  SoftPwmGpio _pwmGpio;
  Timer _timer;

  /// Current brightness of the light.
  double _currentFactor = 0.0;

  /// The light should be animated to when changing the [currentFactor].
  double _endFactor;

  FrontLightController() {
    _pwmGpio = GpioInterface.frontLight;
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
    _pwmGpio.write(value);
  }
}

class BackLightController {
  /// Used when [LightState] is dimmed or on and the drivers isn't braking.
  static const DEFAULT_BRIGHTNESS = 0.4;

  /// Used when [LightState] is dimmed or on and the drivers isn't braking.
  static const BRAKING_BRIGHTNESS = 1.0;

  SoftPwmGpio _pwmGpio;
  GpioLine _brakeInput;
  bool _lightOn = false;
  bool _braking = false;

  BackLightController() {
    _pwmGpio = GpioInterface.backLight;
    _brakeInput = GpioInterface.brakeInput;

    _brakeInput.onEvent.listen(_onBrake);
  }

  /// Turns on or off the back light. Ignores any requests when the drivers brakes.
  void setLight(bool on) {
    _lightOn = on;
    if (!_braking) {
      _lightOn
          ? _setLightBrightness(DEFAULT_BRIGHTNESS)
          : _setLightBrightness(0.0);
    }
  }

  /// Called when there is a change to the [_brakeInput] GPIO.
  void _onBrake(SignalEvent event) {
    final value = _brakeInput.getValue();
    // Check if value has changed.
    if (value != _braking) {
      _braking = value;
      if (_braking) {
        _setLightBrightness(BRAKING_BRIGHTNESS);
      } else {
        setLight(_lightOn);
      }
    }
  }

  /// Sets the brightness light with PWM.
  void _setLightBrightness(double brightness) {
    final value = (brightness * 100).round();
    _pwmGpio.write(value);
  }
}

class LightStripController {}
