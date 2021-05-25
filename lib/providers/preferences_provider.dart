import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the data not stored in specific users.
class PreferencesProvider extends ChangeNotifier {
  PreferencesProvider() {
    SharedPreferences.getInstance().then((data) {
      _preferences = data;
      _init = true;
      notifyListeners();
    });
  }

  late final SharedPreferences _preferences;

  bool _init = false;
  bool get init => _init;

  Future setInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  int? getInt(String key) {
    return _preferences.getInt(key);
  }

  Future setDouble(String key, double value) async {
    await _preferences.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _preferences.getDouble(key);
  }

  bool containsKey(String key) {
    return _preferences.containsKey(key);
  }
}
