import 'package:kart_project/models/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String _dbPath = "/home/pi/data/kart_project.db";
const int _dbVersion = 1;
const String _table = "Profiles";

const String _currentProfilKey = "current_profil";
const String _profilesIndexKey = "profiles_index";

/// Strings for the columns of the SQL database.
const String idColumn = "id";
const String nameColumn = "name";
const String themeModeColumn = "theme_mode";
const String maxSpeedColumn = "max_speed";
const String maxLightBrightnessColumn = "max_light_brightness";
// Locations
const String location1ZoomColumn = "location1_zoom";
const String location1LatColumn = "location1_lat";
const String location1LngColumn = "location1_lng";
const String location2ZoomColumn = "location2_zoom";
const String location2LatColumn = "location2_lat";
const String location2LngColumn = "location2_lng";

/// Manages the database of the profiles. Lets you init, create, update and
/// delete profiles.
class ProfilDatabase {
  SharedPreferences _data;
  Database _db;

  /// The id of the last used profil. Most important when rebooting the device to
  /// check back to the last user.
  int get currentProfilIndex => _data.getInt(_currentProfilKey);

  /// Containes information about the next to use id when creating a new profil.
  /// This is realized, by counting up by one, whenever a new profil is created.
  /// Just using the length of all profiles and adding one to it can result in
  /// various issues when profiles get deleted.
  int get profilesIndex => _data.getInt(_profilesIndexKey);

  /// Opens the database and initalizes SharedPreferences.
  Future initDatabase() async {
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
  }

  /// Creates the Profiles table and adds the default profil to it. Gets
  /// usually called when the database is opened the first time.
  Future _createTable(Database db, int version) async {
    print("Create table");
    await db.execute('''
      CREATE TABLE $_table (
        $idColumn INTEGER PRIMARY KEY,
        $nameColumn TEXT,
        $themeModeColumn INTEGER,
        $maxSpeedColumn INTEGER,
        $maxLightBrightnessColumn REAL,

        $location1ZoomColumn REAL,
        $location1LatColumn REAL,
        $location1LngColumn REAL,
        $location2ZoomColumn REAL,
        $location2LatColumn REAL,
        $location2LngColumn REAL
      )
    ''');
    try {
      await db.insert(_table, Profil(0).toMap());
    } catch (error) {
      print(error);
    }
  }

  /// Creates a profil with the given data.
  Future createProfil(Profil profil) async {
    await _data.setInt(_profilesIndexKey, profilesIndex + 1);
    await _db.insert(_table, profil.toMap());
  }

  /// Returns a list of all profiles.
  Future<List<Map<String, Object>>> getProfilesList() async {
    return await _db.query(_table);
  }

  /// Updates the profil at the [id] with the given [values].
  Future updateProfil(int id, Map<String, Object> values) async {
    await _db.update(
      _table,
      values,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
  }

  /// Sets the current profil to the [id].
  Future setProfil(int id) async {
    await _data.setInt(_currentProfilKey, id);
  }

  /// Deletes the profil data at the given [id].
  Future deleteProfil(int id) async {
    await _db.delete(_table, where: '$idColumn = ?', whereArgs: [id]);
  }
}
