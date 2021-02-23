import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/providers/profil_provider/profil_provider.dart';
import 'package:provider/provider.dart';

/// Provides methods to change the appearance of the kart.
class AppearanceProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  AppearanceProvider(BuildContext context) {
    Profil profil = context.profil().currentProfil;
    _updateAppearanceWithProfil(profil);
  }

  /// Updates the [AppearanceProvider] with the data of the [profil]. Returns
  /// the back the object itself. This is normally called inside a [ProxyProvider]s
  /// update method. Does update all listeners.
  AppearanceProvider update(Profil profil) {
    _updateAppearanceWithProfil(profil);
    notifyListeners();
    return this;
  }

  /// Theme the app should use. Normally implemented in MaterialApp.
  ThemeMode get themeMode => _themeMode;

  /// Updates [themeMode]. Calls the listeners if there are changes to
  /// [themeMode] and [notify] is set to true.
  ///
  /// If [context] is given, the new theme mode setting will be also set in the
  /// profiles database. Use [_indexToThemeMode] to set the [ThemeMode] by index.
  void setThemeMode(ThemeMode mode, {BuildContext context, bool notify: true}) {
    if (themeMode != mode) {
      _themeMode = mode;
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

  /// Should be called if the current profil is switched. Normally called by the
  /// constructor or [update] method. Does not update any listeners.
  void _updateAppearanceWithProfil(Profil profil) {
    setThemeMode(_indexToThemeMode(profil.themeMode), notify: false);
  }
}
