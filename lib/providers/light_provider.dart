import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kart_project/interfaces/gpio_interface.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/interfaces/pwm_gpio_line.dart';
import 'package:kart_project/models/profil.dart';
import 'package:kart_project/providers/boot_provider.dart';
import 'package:provider/provider.dart';

/// Brightness when the [LightState] is set to [LightState.dimmed].
const double dimmedLightBrightness = 0.3;

/// Possible states of the light.
enum LightState {
  off,

  /// Brightness will always be set to [dimmedLightBrightness].
  dimmed,

  /// Brightness will be set to the [_maxLightBrightness] saved in the profil.
  on,
}

/// Lets you control the lights of the kart.
class LightProvider extends ChangeNotifier {
  final _lightController = LightController();
  LightState _lightState = LightState.off;
  double _maxLightBrightness = 0.6;

  LightProvider(BuildContext context) {
    Profil profil = context.profil().currentProfil;
    bool locked = context.read<BootProvider>().locked;
    _updateAppearanceWithProfil(profil);
    _updateAppearanceWithLock(locked);
  }

  /// Updates the [LightProvider] with the data of the [profil] and the
  /// [locked] value of the [BootProvider]. Returns the back the object itself.
  /// This is normally called inside a [ProxyProvider]s update method.
  /// Does update all listeners.
  LightProvider update(Profil profil, bool locked) {
    _updateAppearanceWithProfil(profil);
    _updateAppearanceWithLock(locked);
    notifyListeners();
    return this;
  }

  /// State of the light. Could be `off`, `dimmed` or `on`.
  LightState get lightState => _lightState;

  /// The maximum brightness the light can be set to. This value is specific to
  /// each profil.
  double get maxLightBrightness => _maxLightBrightness;

  /// Sets the brightness of light to the given [factor].
  void setLightBrightness(double factor) {
    _lightController.setLight(factor);
  }

  /// Updates [lightState] and sets the light brightness based on the setting.
  /// Calls the listeners if notify is true.
  void setLightState(LightState state, {bool notify: true}) {
    _lightState = state;
    if (state == LightState.off) {
      setLightBrightness(0.0);
    } else if (state == LightState.dimmed) {
      setLightBrightness(dimmedLightBrightness);
    } else if (state == LightState.on) {
      setLightBrightness(_maxLightBrightness);
    }
    if (notify) notifyListeners();
  }

  /// Updates [maxLightBrightness]. Calls the listeners if there are changes to
  /// [maxLightBrightness] and [notify] is set to true. If [context] is given,
  /// the new theme mode setting will be also set in the profiles database.
  void setMaxLightBrightness(double brightness,
      {BuildContext context, bool notify: true}) {
    if (_maxLightBrightness != brightness) {
      _maxLightBrightness = brightness;
      if (context != null) context.profil().setMaxLightBrightness(brightness);
      if (notify) notifyListeners();
    }
  }

  /// Should be called if the current profil is switched. Updates the max light
  /// brightness and light state. Normally called by the constructor or [update]
  /// method. Does not update any listeners.
  void _updateAppearanceWithProfil(Profil profil) {
    setMaxLightBrightness(profil.maxLightBrightness, notify: false);
    if (_lightState == LightState.on)
      setLightState(LightState.dimmed); // TODO: Test
  }

  /// Called when there is a change to the lock-state. Sets the [_lightState]
  /// to [LightState.dimmed] if locked. Does not update any listeners.
  void _updateAppearanceWithLock(bool locked) {
    if (locked == true && _lightState == LightState.on)
      setLightState(LightState.dimmed, notify: false);
  }

  /// Should be called when the software wants to shutdown.
  void powerOff() {
    setLightState(LightState.off, notify: false);
  }
}

class LightController {
  GpioInterface _gpios;
  PwmGpioLine _pwm;

  LightController() {
    _gpios = GpioInterface();
    final gpio = _gpios.frontLight;
    _pwm = PwmGpioLine(gpio);
  }

  /// Sets the duty cycle of the [_lightPwmPin] to the given [factor].
  void setLight(double factor) {
    // TODO: Implement animation
    _setPwmRatio(factor);
  }

  /// Because of hardware reasons, the brightness of the lights is changing much
  /// faster in higher ranges. By recalculating the factor with the sine, the
  /// factor fits better to the actual behavior.
  void _setPwmRatio(double factor) {
    factor = sin(factor * (pi / 2));
    _pwm.setPwmRatio(factor);
  }
}
