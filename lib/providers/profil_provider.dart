import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kart_project/providers/map_provider.dart';
import 'package:kart_project/providers/preferences_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/extensions.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

enum ProfilsState {
  notInitalized,
  initalized,
  failedToLoadDB,
}

/// Lets you create, update and delete profiles.
class ProfilProvider extends ChangeNotifier {
  final PreferencesProvider _preferences;
  late final _sqlHelper = ProfilsDBHelper(_preferences);
  ProfilsState _state = ProfilsState.notInitalized;
  List<Profil> profiles = [];

  /// Returns the current profil.
  Profil get currentProfil => profiles.firstWhere(
        (profil) => profil.id == _sqlHelper.currentProfilIndex,
      );

  /// Indicates if the database is up and running and initalizing has been
  /// finished.
  ProfilsState get state => _state;

  ProfilProvider(this._preferences) {
    _init();
  }

  /// Initalizes the database. Loads the profiles proberty of the SQL database.
  /// Sets [state] to [ProfilsState.failedToLoadDB] if database crashed.
  Future _init() async {
    try {
      Profil._controller = this;
      await _sqlHelper.initDatabase();
      profiles = await _sqlHelper.getProfilesList();
      _state = ProfilsState.initalized;
    } catch (error) {
      _state = ProfilsState.failedToLoadDB;
    } finally {
      notifyListeners();
    }
  }

  /// Updates the SQL database and notify listeners.
  void _updateProfil(int id, Map<String, Object> sqlData) {
    _sqlHelper.updateProfil(id, sqlData);
    notifyListeners();
  }

  /// Sets the new profil.
  Future switchProfil(BuildContext context, int id) async {
    await _sqlHelper.setProfil(id).catchError((error) {
      context.showExceptionNotification(Strings.failedSettingProfil);
    });
    notifyListeners();
  }

  /// Creates a profil with the default settings and switches to it.
  /// If [name] is null, a default name with the profilId will be created.
  Future createProfil(BuildContext context, {String? name}) async {
    try {
      int profilId = _sqlHelper.profilesIndex;
      if (name == null || name.isEmpty) {
        name = "${Strings.profil} $profilId";
      }
      Profil profil = Profil(profilId, name: name);
      profiles.add(profil);
      await _sqlHelper.createProfil(profil);
      await switchProfil(context, profilId);
      context.showNotification(
        icon: EvaIcons.plusOutline,
        message: Strings.profilWasCreated,
      );
    } catch (error) {
      context.showExceptionNotification(Strings.failedCreatingProfil);
    }
  }

  /// Deletes the profil. Throws an [StateError] if there are no other profiles.
  /// Switches to the first profil in the list.
  Future deleteProfil(BuildContext context, int id) async {
    if (profiles.length <= 1) {
      throw StateError("Deleting all profiles is not supported.");
    }
    try {
      profiles.removeWhere((profil) => profil.id == id);
      await _sqlHelper.deleteProfil(id);
      await switchProfil(context, profiles[0].id);

      context.showNotification(
        icon: EvaIcons.trash2Outline,
        message: Strings.profilWasDeleted,
      );
    } catch (error) {
      context.showExceptionNotification(Strings.failedDeletingProfil);
    }
  }
}

/// Indicates one Profil. For more information on the specific values check out
/// the assosiated provider.
class Profil {
  static ProfilProvider? _controller;
  late int _id;
  String _name = "Standard Profil";
  int _themeMode = ThemeMode.light.index;
  double _maxLightBrightness = 0.6;
  int _lightStripColor = 0xFFD6D6D6;
  int _lowSpeedAlwaysActive = 0;
  double _drivenKilometre = 0.0;
  double _consumedBatteryPercent = 0.0;
  Location? _location1;
  Location? _location2;

  Profil(
    this._id, {
    String? name,
  }) {
    if (name != null) this._name = name;
  }

  /// ID of the profil in the SQL DB.
  int get id => _id;
  String get name => _name;

  /// Sets the name of the Profil. Shows a [ErrorNotification] if failed.
  void setName(BuildContext context, String name) {
    if (name.isEmpty) {
      throw ArgumentError("Name must not be null or empty.");
    }
    try {
      _name = name;
      _update({NAME_COLUMN: name});
      context.showNotification(
        icon: EvaIcons.editOutline,
        message: Strings.editProfil,
      );
    } catch (error) {
      context.showExceptionNotification(Strings.failedUpdatingProfil);
    }
  }

  ThemeMode get themeMode => _themeMode == 1 ? ThemeMode.light : ThemeMode.dark;
  set themeMode(ThemeMode mode) {
    _themeMode = mode.index;
    _update({THEME_MODE_COLUMN: _themeMode});
  }

  double get maxLightBrightness => _maxLightBrightness;
  set maxLightBrightness(double maxBrightness) {
    _maxLightBrightness = maxBrightness;
    _update({MAX_LIHGT_BRIGHTNESS_COLUMN: _maxLightBrightness});
  }

  Color get lightStripColor => Color(_lightStripColor);
  set lightStripColor(Color color) {
    _lightStripColor = color.value;
    _update({LIGHT_STRIP_COLOR_COLUMN: _lightStripColor});
  }

  bool get lowSpeedAlwaysActive => _lowSpeedAlwaysActive == 1;
  set lowSpeedAlwaysActive(bool active) {
    _lowSpeedAlwaysActive = active ? 1 : 0;
    _update({LOW_SPEED_ALWAYS_ACTIVE_COLUMN: _lowSpeedAlwaysActive});
  }

  double get drivenKilometre => _drivenKilometre;
  set drivenKilometre(double kilometre) {
    _drivenKilometre = kilometre;
    _update({DRIVEN_KILOMETRE_COLUMN: _drivenKilometre});
  }

  double get consumedBatteryPercent => _consumedBatteryPercent;
  set consumedBatteryPercent(double percent) {
    _consumedBatteryPercent = percent;
    _update({CONSUMED_BATTERY_PERCENT: _consumedBatteryPercent});
  }

  Location? get location1 => _location1;
  set location1(Location? location) {
    if (location != null) {
      _location1 = location;
      _update(location.toProfilMap(1)!);
    }
  }

  Location? get location2 => _location2;
  set location2(Location? location) {
    if (location != null) {
      _location2 = location;
      _update(location.toProfilMap(2)!);
    }
  }

  /// Updates the profil in the [ProfilProvider].
  void _update(Map<String, Object> sqlData) {
    print("Update Data: $sqlData");
    _controller!._updateProfil(id, sqlData);
  }

  Map<String, Object> toMap() {
    var data = <String, Object>{
      ID_COLUMN: _id,
      NAME_COLUMN: _name,
      THEME_MODE_COLUMN: _themeMode,
      MAX_LIHGT_BRIGHTNESS_COLUMN: _maxLightBrightness,
      LIGHT_STRIP_COLOR_COLUMN: _lightStripColor,
      LOW_SPEED_ALWAYS_ACTIVE_COLUMN: _lowSpeedAlwaysActive,
      DRIVEN_KILOMETRE_COLUMN: _drivenKilometre,
      CONSUMED_BATTERY_PERCENT: _consumedBatteryPercent,
    };
    if (location1 != null) data.addAll(location1!.toProfilMap(1)!);
    if (location2 != null) data.addAll(location2!.toProfilMap(2)!);
    return data;
  }

  Profil.fromMap(Map<String, dynamic> profil) {
    _id = profil[ID_COLUMN];
    _name = profil[NAME_COLUMN];
    _themeMode = profil[THEME_MODE_COLUMN];
    _maxLightBrightness = profil[MAX_LIHGT_BRIGHTNESS_COLUMN];
    _lightStripColor = profil[LIGHT_STRIP_COLOR_COLUMN];
    _lowSpeedAlwaysActive = profil[LOW_SPEED_ALWAYS_ACTIVE_COLUMN];
    _drivenKilometre = profil[DRIVEN_KILOMETRE_COLUMN];
    _consumedBatteryPercent = profil[CONSUMED_BATTERY_PERCENT];
    if (profil[LOCATION1_ZOOM_COLUMN] != null &&
        profil[LOCATION1_LAT_COLUMN] != null &&
        profil[LOCATION1_LNG_COLUMN] != null) {
      _location1 = Location.fromProfilMap(1, profil);
    }
    if (profil[LOCATION2_ZOOM_COLUMN] != null &&
        profil[LOCATION2_LAT_COLUMN] != null &&
        profil[LOCATION2_LNG_COLUMN] != null) {
      _location2 = Location.fromProfilMap(2, profil);
    }
  }
}

const _DB_PATH = "/home/pi/data/kart_project_profiles.db";
const _DB_VERSION = 1;
const _TABLE = "Profiles";

const _CURRENT_PROFIL_KEY = "current_profil";
const _PROFILES_INDEX_KEY = "profiles_index";

/// Strings for the columns of the SQL database.
const ID_COLUMN = "id";
const NAME_COLUMN = "name";
const THEME_MODE_COLUMN = "theme_mode";
const MAX_LIHGT_BRIGHTNESS_COLUMN = "max_light_brightness";
const LIGHT_STRIP_COLOR_COLUMN = "light_strip_color_column";
const LOW_SPEED_ALWAYS_ACTIVE_COLUMN = "low_speed_always_active_colum";
const DRIVEN_KILOMETRE_COLUMN = "driven_kilometre_column";
const CONSUMED_BATTERY_PERCENT = "consumed_battery_percent";
// Locations
const LOCATION1_ZOOM_COLUMN = "location1_zoom";
const LOCATION1_LAT_COLUMN = "location1_lat";
const LOCATION1_LNG_COLUMN = "location1_lng";
const LOCATION2_ZOOM_COLUMN = "location2_zoom";
const LOCATION2_LAT_COLUMN = "location2_lat";
const LOCATION2_LNG_COLUMN = "location2_lng";

/// Manages the database of the profiles. Lets you init, create, update and
/// delete profiles.
class ProfilsDBHelper {
  ProfilsDBHelper(this._preferences);

  final PreferencesProvider _preferences;
  late final Database _db;

  /// The id of the last used profil. Most important when rebooting the device to
  /// check back to the last user.
  int get currentProfilIndex => _preferences.getInt(_CURRENT_PROFIL_KEY)!;

  /// Containes information about the next to use id when creating a new profil.
  /// This is realized, by counting up by one, whenever a new profil is created.
  /// Just using the length of all profiles and adding one to it can result in
  /// various issues when profiles get deleted.
  int get profilesIndex => _preferences.getInt(_PROFILES_INDEX_KEY)!;

  /// Opens the database and initalizes SharedPreferences.
  Future initDatabase() async {
    var dbFactory = databaseFactoryFfi;
    _db = await dbFactory.openDatabase(
      _DB_PATH,
      options: OpenDatabaseOptions(
        version: _DB_VERSION,
        onCreate: _createTable,
      ),
    );

    if (!_preferences.containsKey(_PROFILES_INDEX_KEY)) {
      await _preferences.setInt(_PROFILES_INDEX_KEY, 1);
    }
    if (!_preferences.containsKey(_CURRENT_PROFIL_KEY)) {
      await _preferences.setInt(_CURRENT_PROFIL_KEY, 0);
    }
  }

  /// Creates the Profiles table and adds the default profil to it. Gets
  /// usually called when the database is opened the first time.
  Future _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_TABLE (
        $ID_COLUMN INTEGER PRIMARY KEY,
        $NAME_COLUMN TEXT,
        $THEME_MODE_COLUMN INTEGER,
        $MAX_LIHGT_BRIGHTNESS_COLUMN REAL,
        $LIGHT_STRIP_COLOR_COLUMN INTEGER,
        $LOW_SPEED_ALWAYS_ACTIVE_COLUMN INTEGER,
        $DRIVEN_KILOMETRE_COLUMN REAL,
        $CONSUMED_BATTERY_PERCENT REAL,

        $LOCATION1_ZOOM_COLUMN REAL,
        $LOCATION1_LAT_COLUMN REAL,
        $LOCATION1_LNG_COLUMN REAL,
        $LOCATION2_ZOOM_COLUMN REAL,
        $LOCATION2_LAT_COLUMN REAL,
        $LOCATION2_LNG_COLUMN REAL
      )
    ''');
    await db.insert(_TABLE, Profil(0).toMap());
  }

  /// Creates a profil with the given data.
  Future createProfil(Profil profil) async {
    await _preferences.setInt(_PROFILES_INDEX_KEY, profilesIndex + 1);
    await _db.insert(_TABLE, profil.toMap());
  }

  /// Returns a list of all profiles.
  Future<List<Profil>> getProfilesList() async {
    final query = await _db.query(_TABLE);
    return List.generate(
      query.length,
      (index) => Profil.fromMap(query.elementAt(index)),
    );
  }

  /// Updates the profil at the [id] with the given [values].
  Future updateProfil(int id, Map<String, Object> values) async {
    await _db.update(
      _TABLE,
      values,
      where: '$ID_COLUMN = ?',
      whereArgs: [id],
    );
  }

  /// Sets the current profil to the [id].
  Future setProfil(int id) async {
    await _preferences.setInt(_CURRENT_PROFIL_KEY, id);
  }

  /// Deletes the profil data at the given [id].
  Future deleteProfil(int id) async {
    await _db.delete(_TABLE, where: '$ID_COLUMN = ?', whereArgs: [id]);
  }
}
