import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kart_project/providers/map_provider.dart';
import 'package:kart_project/providers/motor_controller_provider.dart';
import 'package:kart_project/providers/preferences_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/extensions.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

enum UsersState {
  notInitalized,
  initalized,
  failedToLoadDB,
}

/// Lets you create, update and delete users.
class UserProvider extends ChangeNotifier {
  final PreferencesProvider _preferences;
  late final _sqlHelper = UsersDBHelper(_preferences);
  UsersState _state = UsersState.notInitalized;
  List<User> users = [];

  /// Returns the current user.
  User get currentUser => users.firstWhere(
        (user) => user.id == _sqlHelper.currentUserIndex,
      );

  /// Indicates if the database is up and running and initalizing has been
  /// finished.
  UsersState get state => _state;

  UserProvider(this._preferences) {
    _init();
  }

  /// Initalizes the database. Loads the users proberty of the SQL database.
  /// Sets [state] to [UsersState.failedToLoadDB] if database crashed.
  Future _init() async {
    try {
      User._controller = this;
      await _sqlHelper.initDatabase();
      users = await _sqlHelper.getUsersList();
      _state = UsersState.initalized;
    } catch (error) {
      _state = UsersState.failedToLoadDB;
    } finally {
      notifyListeners();
    }
  }

  /// Updates the SQL database and notify listeners.
  void _updateUser(int id, Map<String, Object> sqlData) {
    _sqlHelper.updateUser(id, sqlData);
    notifyListeners();
  }

  /// Sets the new user.
  Future switchUser(BuildContext context, int id) async {
    await _sqlHelper.setUser(id).catchError((error) {
      context.showExceptionNotification(Strings.failedSettingUser);
    });
    notifyListeners();
  }

  /// Creates a user with the default settings and switches to it.
  /// If [name] is null, a default name with the userId will be created.
  Future createUser(BuildContext context, {String? name}) async {
    try {
      int userId = _sqlHelper.usersIndex;
      if (name == null || name.isEmpty) {
        name = "${Strings.user} $userId";
      }
      User user = User(userId, name: name);
      users.add(user);
      await _sqlHelper.createUser(user);
      await switchUser(context, userId);
      context.showNotification(
        icon: EvaIcons.plusOutline,
        message: Strings.userWasCreated,
      );
    } catch (error) {
      context.showExceptionNotification(Strings.failedCreatingUser);
    }
  }

  /// Deletes the user. Throws an [StateError] if there are no other users.
  /// Switches to the first user in the list.
  Future deleteUser(BuildContext context, int id) async {
    if (users.length <= 1) {
      throw StateError("Deleting all users is not supported.");
    }
    try {
      users.removeWhere((user) => user.id == id);
      await _sqlHelper.deleteUser(id);
      await switchUser(context, users[0].id);

      context.showNotification(
        icon: EvaIcons.trash2Outline,
        message: Strings.userWasDeleted,
      );
    } catch (error) {
      context.showExceptionNotification(Strings.failedDeletingUser);
    }
  }
}

/// Indicates one user. For more information on the specific values check out
/// the assosiated provider.
class User {
  static UserProvider? _controller;
  late int _id;
  late UserRangeProfil _rangeProfil = UserRangeProfil(this);
  String _name = "Standard Benutzer";
  int _themeMode = ThemeMode.light.index;
  double _maxLightBrightness = 0.6;
  int _lightStripColor = 0xFFD6D6D6;
  int _lowSpeedAlwaysActive = 0;
  Location? _location1;
  Location? _location2;

  User(
    this._id, {
    String? name,
  }) {
    if (name != null) this._name = name;
  }

  /// ID of the user in the SQL DB.
  int get id => _id;
  String get name => _name;

  /// Sets the name of the user. Shows a [ErrorNotification] if failed.
  void setName(BuildContext context, String name) {
    if (name.isEmpty) {
      throw ArgumentError("Name must not be null or empty.");
    }
    try {
      _name = name;
      _update({NAME_COLUMN: name});
      context.showNotification(
        icon: EvaIcons.editOutline,
        message: Strings.editUser,
      );
    } catch (error) {
      context.showExceptionNotification(Strings.failedUpdatingUser);
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

  UserRangeProfil get rangeProfil => _rangeProfil;
  set rangeProfil(UserRangeProfil rangeProfil) {
    _rangeProfil = rangeProfil;
    _update(_rangeProfil.toUserMap());
  }

  Location? get location1 => _location1;
  set location1(Location? location) {
    if (location != null) {
      _location1 = location;
      _update(location.toUserMap(1)!);
    }
  }

  Location? get location2 => _location2;
  set location2(Location? location) {
    if (location != null) {
      _location2 = location;
      _update(location.toUserMap(2)!);
    }
  }

  /// Updates the user in the [UserProvider].
  void _update(Map<String, Object> sqlData) {
    print("Update Data: $sqlData");
    _controller!._updateUser(id, sqlData);
  }

  Map<String, Object> toMap() {
    var data = <String, Object>{
      ID_COLUMN: _id,
      NAME_COLUMN: _name,
      THEME_MODE_COLUMN: _themeMode,
      MAX_LIHGT_BRIGHTNESS_COLUMN: _maxLightBrightness,
      LIGHT_STRIP_COLOR_COLUMN: _lightStripColor,
      LOW_SPEED_ALWAYS_ACTIVE_COLUMN: _lowSpeedAlwaysActive,
    };
    data.addAll(_rangeProfil.toUserMap());
    if (location1 != null) data.addAll(location1!.toUserMap(1)!);
    if (location2 != null) data.addAll(location2!.toUserMap(2)!);
    return data;
  }

  User.fromMap(Map<String, dynamic> mapData) {
    _id = mapData[ID_COLUMN];
    _name = mapData[NAME_COLUMN];
    _themeMode = mapData[THEME_MODE_COLUMN];
    _maxLightBrightness = mapData[MAX_LIHGT_BRIGHTNESS_COLUMN];
    _lightStripColor = mapData[LIGHT_STRIP_COLOR_COLUMN];
    _lowSpeedAlwaysActive = mapData[LOW_SPEED_ALWAYS_ACTIVE_COLUMN];
    _rangeProfil = UserRangeProfil.fromUserMap(this, mapData);
    if (mapData[LOCATION1_ZOOM_COLUMN] != null &&
        mapData[LOCATION1_LAT_COLUMN] != null &&
        mapData[LOCATION1_LNG_COLUMN] != null) {
      _location1 = Location.fromUserMap(1, mapData);
    }
    if (mapData[LOCATION2_ZOOM_COLUMN] != null &&
        mapData[LOCATION2_LAT_COLUMN] != null &&
        mapData[LOCATION2_LNG_COLUMN] != null) {
      _location2 = Location.fromUserMap(2, mapData);
    }
  }
}

const _DB_PATH = "/home/pi/data/kart_project_users.db";
const _DB_VERSION = 1;
const _TABLE = "Users";

const _CURRENT_USER_KEY = "current_user";
const _USERS_INDEX_KEY = "users_index";

/// Strings for the columns of the SQL database.
const ID_COLUMN = "id";
const NAME_COLUMN = "name";
const THEME_MODE_COLUMN = "theme_mode";
const MAX_LIHGT_BRIGHTNESS_COLUMN = "max_light_brightness";
const LIGHT_STRIP_COLOR_COLUMN = "light_strip_color";
const LOW_SPEED_ALWAYS_ACTIVE_COLUMN = "low_speed_always_active";
const RANGE_PROFIL_KILOMETRE_COLUMN = "range_profil_kilometre";
const RANGE_PROFIL_BATTERY_PERCENT_COLUMN = "range_profil_battery_percent";
// Locations
const LOCATION1_ZOOM_COLUMN = "location1_zoom";
const LOCATION1_LAT_COLUMN = "location1_lat";
const LOCATION1_LNG_COLUMN = "location1_lng";
const LOCATION2_ZOOM_COLUMN = "location2_zoom";
const LOCATION2_LAT_COLUMN = "location2_lat";
const LOCATION2_LNG_COLUMN = "location2_lng";

/// Manages the database of the users. Lets you init, create, update and
/// delete users.
class UsersDBHelper {
  UsersDBHelper(this._preferences);

  final PreferencesProvider _preferences;
  late final Database _db;

  /// The id of the last used user. Most important when rebooting the device to
  /// check back to the last user.
  int get currentUserIndex => _preferences.getInt(_CURRENT_USER_KEY)!;

  /// Containes information about the next to use id when creating a new user.
  /// This is realized, by counting up by one, whenever a new user is created.
  /// Just using the length of all users and adding one to it can result in
  /// various issues when users get deleted.
  int get usersIndex => _preferences.getInt(_USERS_INDEX_KEY)!;

  Future initDatabase() async {
    var dbFactory = databaseFactoryFfi;
    _db = await dbFactory.openDatabase(
      _DB_PATH,
      options: OpenDatabaseOptions(
        version: _DB_VERSION,
        onCreate: _createTable,
      ),
    );

    if (!_preferences.containsKey(_USERS_INDEX_KEY)) {
      await _preferences.setInt(_USERS_INDEX_KEY, 1);
    }
    if (!_preferences.containsKey(_CURRENT_USER_KEY)) {
      await _preferences.setInt(_CURRENT_USER_KEY, 0);
    }
  }

  /// Creates the users table and adds the default user to it. Gets
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
        $RANGE_PROFIL_KILOMETRE_COLUMN REAL,
        $RANGE_PROFIL_BATTERY_PERCENT_COLUMN REAL,

        $LOCATION1_ZOOM_COLUMN REAL,
        $LOCATION1_LAT_COLUMN REAL,
        $LOCATION1_LNG_COLUMN REAL,
        $LOCATION2_ZOOM_COLUMN REAL,
        $LOCATION2_LAT_COLUMN REAL,
        $LOCATION2_LNG_COLUMN REAL
      )
    ''');
    await db.insert(_TABLE, User(0).toMap());
  }

  /// Creates a user with the given data.
  Future createUser(User user) async {
    await _preferences.setInt(_USERS_INDEX_KEY, usersIndex + 1);
    await _db.insert(_TABLE, user.toMap());
  }

  /// Returns a list of all users.
  Future<List<User>> getUsersList() async {
    final query = await _db.query(_TABLE);
    return List.generate(
      query.length,
      (index) => User.fromMap(query.elementAt(index)),
    );
  }

  /// Updates the user at the [id] with the given [values].
  Future updateUser(int id, Map<String, Object> values) async {
    await _db.update(
      _TABLE,
      values,
      where: '$ID_COLUMN = ?',
      whereArgs: [id],
    );
  }

  /// Sets the current user to the [id].
  Future setUser(int id) async {
    await _preferences.setInt(_CURRENT_USER_KEY, id);
  }

  /// Deletes the user data at the given [id].
  Future deleteUser(int id) async {
    await _db.delete(_TABLE, where: '$ID_COLUMN = ?', whereArgs: [id]);
  }
}
