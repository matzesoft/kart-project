import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/providers/profil_provider.dart';
import 'package:provider/provider.dart';

/// Provides methods to change the appearance of the kart.
class AppearanceProvider extends ChangeNotifier {
  Profil _profil;

  AppearanceProvider(this._profil);

  /// Updates the [AppearanceProvider] with the data of the [newProfil]. Returns
  /// the back the object itself. This is normally called inside a [ProxyProvider]s
  /// update method. Does update all listeners.
  AppearanceProvider update(Profil newProfil) {
    _profil = newProfil;
    notifyListeners();
    return this;
  }

  /// Theme the app should use. Normally implemented in MaterialApp.
  ThemeMode get themeMode => _profil.themeMode;
  set themeMode(ThemeMode mode) => _profil.themeMode = mode;
}
