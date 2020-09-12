import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kart_project/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String _dbPath = "/home/pi/data/kart_project.db";
const int _dbVersion = 1;
const String _table = "Profiles";

/// The id of the last used profil. Most important when rebooting the device to
/// check back to the last user.
const String _currentProfilKey = "current_profil";

/// Containes information about the next to use id when creating a new profil.
/// This is realized, by counting up by one, whenever a new profil is created.
/// Just using the length of all profiles and adding one to it can result in
/// various issues when profiles get deleted.
const String _profilesIndexKey = "profiles_index";

// Strings for the columns of the SQL database.
const String _idColumn = "id";
const String _nameColumn = "name";
const String _themeModeColumn = "theme_mode";
const String _maxSpeedColumn = "max_speed";
const String _lightBrightnessColumn = "light_brightness";

/// Indicates one Profil.
///
/// [themeMode] determs if the theme should adapt based on time `(value: 0)`,
/// always be light `(value: 1)`or dark `(value: 2)`.
///
/// [maxSpeed] is the speed which the user is allowed to maximum drive.
/// [lightBrightness] is the brightness the light can maximum get. Check the
/// [LightsProvider] for more information.
class Profil {
  int id;
  String name;
  int themeMode;
  int maxSpeed;
  double lightBrightness;

  Profil({
    this.id,
    this.name,
    this.themeMode,
    this.maxSpeed,
    this.lightBrightness,
  });

  Map<String, Object> toMap() {
    return <String, Object>{
      _idColumn: id,
      _nameColumn: name,
      _themeModeColumn: themeMode,
      _maxSpeedColumn: maxSpeed,
      _lightBrightnessColumn: lightBrightness,
    };
  }

  Profil.fromMap(Map<String, dynamic> profil) {
    id = profil[_idColumn];
    name = profil[_nameColumn];
    themeMode = profil[_themeModeColumn];
    maxSpeed = profil[_maxSpeedColumn];
    lightBrightness = profil[_lightBrightnessColumn];
  }
}

/// Manages the database and gives options to control the profiles.
class ProfilProvider extends ChangeNotifier {
  SharedPreferences _data;
  Database _db;

  /// Indicates if the database is up and running and initalizing has been
  /// finished.
  bool initalized = false;

  /// List of all profiles.
  List<Profil> profiles;

  /// Returns the current profil.
  Profil get currentProfil {
    return profiles.firstWhere(
      (profil) => profil.id == _data.getInt(_currentProfilKey),
    );
  }

  ProfilProvider(BuildContext context) {
    _init(context);
  }

  /// Opens the datbase. Initalizes SharedPreferences and sets the profil based
  /// on the [_currentProfilKey].
  Future _init(BuildContext context) async {
    print("Called _init");
    var dbFactory = databaseFactoryFfi;
    _db = await dbFactory.openDatabase(
      _dbPath,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: _createTable,
      ),
    );

    _data = await SharedPreferences.getInstance();
    if (!_data.containsKey(_profilesIndexKey)) {
      await _data.setInt(_profilesIndexKey, 1);
    }
    if (!_data.containsKey(_currentProfilKey)) {
      await _data.setInt(_currentProfilKey, 0);
    }

    await setProfil(context, _data.getInt(_currentProfilKey));
    await _updateProfilesList();
    initalized = true;
    notifyListeners();
  }

  /// Creates the Profiles table and adds the default profil to it. Gets
  /// usually called when the database is opened the first time.
  Future _createTable(Database db, int version) async {
    print("Called create Table");
    await db.execute('''
      CREATE TABLE $_table (
        $_idColumn INTEGER PRIMARY KEY,
        $_nameColumn TEXT,
        $_themeModeColumn INTEGER,
        $_maxSpeedColumn INTEGER,
        $_lightBrightnessColumn REAL
      )
    ''');
    await db.insert(
      _table,
      Profil(
        id: 0,
        name: "Standard Profil",
        themeMode: 0,
        maxSpeed: 80,
        lightBrightness: 0.6,
      ).toMap(),
    );
  }

  /// Updates the [profiles] proberty.
  Future _updateProfilesList() async {
    List<Map> query = await _db.query(_table);
    profiles = List.generate(
      query.length,
      (index) => Profil.fromMap(query.elementAt(index)),
    );
  }

  Future _updateProfil(int id, Map<String, Object> values) async {
    await _db.update(
      _table,
      values,
      where: '$_idColumn = ?',
      whereArgs: [id],
    );
    await _updateProfilesList();
    notifyListeners();
  }

  /// Sets the new profil and updates all settings.
  Future setProfil(BuildContext context, int id, {bool force: false}) async {
    await _data.setInt(_currentProfilKey, id);
    List<Map> query = await _db.query(
      _table,
      where: '$_idColumn = ?',
      whereArgs: [id],
    );
    Profil profil = Profil.fromMap(query.first);
    // TODO: Implement needed Providers
    notifyListeners();
  }

  /// Creates a profil with the default settings and switches to it.
  /// If [name] is null, a default name with the profilId will be created.
  Future createProfil(BuildContext context, {String name}) async {
    int profilId = _data.getInt(_profilesIndexKey);
    if (name == null || name.isEmpty) {
      name = "${Strings.profil} $profilId";
    }
    Profil profil = Profil(
      id: profilId,
      name: name,
      themeMode: 0,
      maxSpeed: 80,
      lightBrightness: 0.6,
    );
    await _db.insert(_table, profil.toMap());
    await _updateProfilesList();
    await _data.setInt(_profilesIndexKey, profilId + 1);
    await setProfil(context, profilId);
  }

  /// Updates the name of the profil.
  Future setName(int id, String name) async {
    if (name == null || name.isEmpty)
      throw ArgumentError("Name must not be null or empty.");
    await _updateProfil(id, <String, Object>{_nameColumn: name});
  }

  /// Updates the themeMode setting. Only allows 0, 1 and 2 as parameter.
  Future setThemeMode(int id, int themeMode) async {
    if (themeMode > 2 || themeMode < 0) {
      throw ArgumentError(
        "ThemeMode only allows 0 (SystemMode), 1 (LightMode) and 2 (DarkMode).",
      );
    }
    await _updateProfil(id, <String, Object>{_themeModeColumn: themeMode});
  }

  /// Updates the max speed setting. Only allows values between 10 and 100.
  Future setMaxSpeed(int id, int maxSpeed) async {
    if (maxSpeed < 10 || maxSpeed > 100) {
      throw ArgumentError(
        "Max speed is only allowed to be set between 10 km/h and 100 km/h.",
      );
    }
    await _updateProfil(id, <String, Object>{_maxSpeedColumn: maxSpeed});
  }

  /// Updates the light brightness setting. Only allows values between 0.3 and 1.
  Future setLightBrightness(int id, double lightBrightness) async {
    if (lightBrightness < 0.3 || lightBrightness > 1.0) {
      throw ArgumentError(
        "Light brightness is only allowed to be set between 0.3 and 1.",
      );
    }
    await _updateProfil(
      id,
      <String, Object>{_lightBrightnessColumn: lightBrightness},
    );
  }

  /// Deletes the profil. If no id is given the current profil will be deleted.
  /// Throws an [StateError] if there are no other profiles. Switches to the
  /// first profil in the list, if requested profil is the currentUser.
  Future deleteProfil(BuildContext context, {int id}) async {
    if (profiles.length <= 1) {
      throw StateError(
        "There is at least one profil needed. Deleting all profiles is not supported.",
      );
    }
    id ??= currentProfil.id;
    await _db.delete(_table, where: '$_idColumn = ?', whereArgs: [id]);
    await _updateProfilesList();
    await setProfil(context, profiles[0].id);
  }
}
