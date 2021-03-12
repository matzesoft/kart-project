import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/interfaces/gpio_interface.dart';
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
  FrontLightController frontLight;
  BackLightController backLight;
  LightStripController lightStrip;
  LightState _lightState = LightState.off;

  LightProvider(BuildContext context) {
    frontLight = FrontLightController(this);
    backLight = BackLightController();
    lightStrip = LightStripController(this);

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
  void setLightState(LightState state) {
    _lightState = state;
    frontLight._setLightByState(state);
    backLight._setLightByState(state);
    lightStrip._setLightByState(state);
    notifyListeners();
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
      setLightState(LightState.dimmed);
  }

  /// Should be called when the software wants to shutdown.
  void powerOff() {
    setLightState(LightState.off);
  }
}

/// How long one period takes. Calculated with a frequency of `30Hz`:
/// `1 / 30Hz = 0.03125sek`
const _PERIOD_DURATION = Duration(milliseconds: 31);

/// How much the light brightness changes per period.
const _PERIOD_CHANGE = 0.02;

/// Controls the PWM values of the front light.
class FrontLightController {
  LightProvider _controller;
  SoftPwmGpio _pwmGpio = GpioInterface.frontLight;
  Timer _timer;
  double _currentFactor = 0.0;
  double _endFactor; // The light should be animated to.

  FrontLightController(this._controller);

  /// Current brightness of the light.
  double get currentFactor => _currentFactor;
  set currentFactor(double factor) {
    _currentFactor = factor;
    _setPwmRatio(_currentFactor);
  }

  /// The maximum brightness the light can be set to.
  double get maxBrightness => _controller._profil.maxLightBrightness;
  set maxBrightness(double maxBrightness) {
    _controller._profil.maxLightBrightness = maxBrightness;
  }

  void animateLight(double factor) {
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

  /// Animates the light dependend on the [LightState].
  void _setLightByState(LightState state) {
    if (state == LightState.off) {
      animateLight(0.0);
    } else {
      state == LightState.dimmed
          ? animateLight(FRONT_DIMMED_BRIGHTNESS)
          : animateLight(maxBrightness);
    }
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

/// Used when [LightState] is dimmed or on and the drivers isn't braking.
const DEFAULT_BRIGHTNESS = 0.4;

/// Used when [LightState] is dimmed or on and the drivers isn't braking.
const BRAKING_BRIGHTNESS = 1.0;

class BackLightController {
  SoftPwmGpio _pwmGpio = GpioInterface.backLight;
  GpioLine _brakeInput = GpioInterface.brakeInput;
  bool _active = false;
  bool _braking = false;

  BackLightController() {
    _brakeInput.onEvent.listen(_onBrake);
  }

  /// Wether the backlight is on or off.
  bool get active => _active;
  set active(bool on) {
    _active = on;
    // Ignores any requests when the drivers brakes.
    if (!_braking) {
      _active
          ? _setLightBrightness(DEFAULT_BRIGHTNESS)
          : _setLightBrightness(0.0);
    }
  }

  /// Sets the light dependend on the [LightState].
  void _setLightByState(LightState state) {
    if (state == LightState.off) {
      active = false;
    } else {
      active = true;
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
        active = _active;
      }
    }
  }

  /// Sets the brightness light with PWM.
  void _setLightBrightness(double brightness) {
    final value = (brightness * 100).round();
    _pwmGpio.write(value);
  }
}

const LIGHT_STRIP_COLORS = [
  Color(0xFFD6D6D6),
  Color(0xFF00FFFF),
  Color(0xFFFF00FF),
  Color(0xFFFFFF00),
  Color(0xFFFF0000),
  Color(0xFF00FF00),
  Color(0xFF0000FF),
  Color(0xFF424242),
];

class LightStripController {
  LightProvider _controller;
  bool _active = false;
  final _red = GpioInterface.ledRed;
  final _green = GpioInterface.ledGreen;
  final _blue = GpioInterface.ledBlue;

  LightStripController(this._controller);

  Color get color => _controller._profil.lightStripColor;
  set color(Color color) {
    _controller._profil.lightStripColor = color;
    _updateLightStrip();
  }

  bool get active => _active;
  set active(bool on) {
    _active = on;
    _updateLightStrip();
  }

  /// Checks [active] and sets the GPIOs to the current [color] of true.
  void _updateLightStrip() {
    if (active) {
      color.red > 128 ? _red.setValue(true) : _red.setValue(false);
      color.green > 128 ? _green.setValue(true) : _green.setValue(false);
      color.blue > 128 ? _blue.setValue(true) : _blue.setValue(false);
    } else {
      _red.setValue(false);
      _green.setValue(false);
      _blue.setValue(false);
    }
  }

  /// Sets the light dependend on the [LightState].
  void _setLightByState(LightState state) {
    state == LightState.off ? active = false : active = true;
  }
}
