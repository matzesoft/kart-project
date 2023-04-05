import 'package:flutter/material.dart';
import 'package:kart_project/providers/user_provider.dart';
import 'package:provider/provider.dart';

/// Provides methods to change the appearance of the kart.
class AppearanceProvider extends ChangeNotifier {
  User _user;

  AppearanceProvider(this._user);

  /// Updates the [AppearanceProvider] with the data of the [newUser]. Returns
  /// the back the object itself. This is normally called inside a [ProxyProvider]s
  /// update method. Does update all its listeners.
  AppearanceProvider update(User newUser) {
    _user = newUser;
    notifyListeners();
    return this;
  }

  /// Theme of the app. Must be implemented in MaterialApp.
  ThemeMode get themeMode => _user.themeMode;
  set themeMode(ThemeMode mode) => _user.themeMode = mode;
}
