import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/interfaces/pwm_interface/pwm_interface.dart';
import 'package:kart_project/models/profil.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/providers/boot_provider.dart';

/// Brightness when the [LightState] is set to [LightState.dimmed].
const double _dimmedLight = 0.3;

/// Pin the front light is connected to.
const int _lightPwmPin = 12;

/// Possible states of the light.
enum LightState {
  off,

  /// Brightness will always be set to [_dimmedLight].
  dimmed,

  /// Brightness will be set to the [maxLightBrightness] saved in the profil.
  on,
}

/// Provides methods to change the appearance of the kart.
class AppearanceProvider extends ChangeNotifier {
  final _pwm = PwmInterface();
  LightState lightState = LightState.off;
  double maxLightBrightness = 0.6;
  ThemeMode themeMode = ThemeMode.light;

  AppearanceProvider(BuildContext context) {
    Profil profil = context.profil().currentProfil;
    bool locked = context.read<BootProvider>().locked;
    _updateAppearanceWithProfil(profil);
    _updateAppearanceWithLock(locked);
  }

  /// Updates the [AppearanceProvider] with the data of the [profil] and the
  /// [locked] value of the [BootProvider]. Returns the back the object itself.
  /// This is normally called inside a [ProxyProvider]s update method.
  AppearanceProvider update(Profil profil, bool locked) {
    _updateAppearanceWithProfil(profil);
    _updateAppearanceWithLock(locked);
    return this;
  }

  /// Sets the duty cycle of the [_lightPwmPin] to the given [factor].
  void _setLight(double factor) {
    // TODO: Animation
    _pwm.setDutyCycle(_lightPwmPin, factor);
  }

  /// Updates [lightState] and sets the light brightness based on the setting.
  /// Calls the listeners if there are changes to [lightState].
  void setLightState(LightState state, {bool notify}) {
    if (lightState != state) {
      lightState = state;
      if (state == LightState.off) _setLight(0.0);
      if (state == LightState.dimmed) _setLight(_dimmedLight);
      if (state == LightState.on) _setLight(maxLightBrightness);
      notifyListeners();
    }
  }

  void setMaxLightBrightness(double brightness,
      {BuildContext context, bool notify}) {
    // TODO: Implement
  }

  /// Updates [themeMode]. Calls the listeners if there are changes to
  /// [themeMode] and [notify] is set to true.
  ///
  /// If [context] is given, the new theme mode setting will be also set in the
  /// profiles database. Use [_indexToThemeMode] to set the [ThemeMode] by index.
  void setThemeMode(ThemeMode mode, {BuildContext context, bool notify: true}) {
    if (themeMode != mode) {
      themeMode = mode;
      if (context != null) context.profil().setThemeMode(themeMode.index);
      if (notify) notifyListeners();
    }
  }

  /// Returns the [ThemeMode] at the given index.
  /// `1 == ThemeMode.light`; `2 == ThemeMode.dark`
  ThemeMode _indexToThemeMode(int index) {
    if (!(index == 1 || index == 2))
      throw ArgumentError("Index of ThemeMode only allows 1 or 2: $index");
    return index == 1 ? ThemeMode.light : ThemeMode.dark;
  }

  /// Should be called if the current profil is switched. Updates all values
  /// implemented by the [AppearanceProvider]. Normally called by the constructor.
  void _updateAppearanceWithProfil(Profil profil) {
    setThemeMode(_indexToThemeMode(profil.themeMode), notify: false);
    // TODO: Full implementation
  }

  /// Called when there is a change to the lock-state. Sets the [lightState]
  /// to [LightState.dimmed] if locked.
  void _updateAppearanceWithLock(bool locked) {
    if (locked == true && lightState == LightState.on)
      setLightState(LightState.dimmed, notify: false);
  }
}
