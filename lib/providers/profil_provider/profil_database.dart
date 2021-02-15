import 'package:kart_project/models/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String _DB_PATH = "/home/pi/data/kart_project.db";
const int _DB_VERSION = 1;
const String _TABLE = "Profiles";

const String _CURRENT_PROFIL_KEY = "current_profil";
const String _PROFILES_INDEX_KEY = "profiles_index";

/// Strings for the columns of the SQL database.
const String ID_COLUMN = "id";
const String NAME_COLUMN = "name";
const String THEME_MODE_COLUMN = "theme_mode";
const String MAX_SPEED_COLUMN = "max_speed";
const String MAX_LIHGT_BRIGHTNESS_COLUMN = "max_light_brightness";
// Locations
const String LOCATION1_ZOOM_COLUMN = "location1_zoom";
const String LOCATION1_LAT_COLUMN = "location1_lat";
const String LOCATION1_LNG_COLUMN = "location1_lng";
const String LOCATION2_ZOOM_COLUMN = "location2_zoom";
const String LOCATION2_LAT_COLUMN = "location2_lat";
const String LOCATION2_LNG_COLUMN = "location2_lng";

/// Manages the database of the profiles. Lets you init, create, update and
/// delete profiles.
class ProfilDatabase {
  SharedPreferences _data;
  Database _db;

  /// The id of the last used profil. Most important when rebooting the device to
  /// check back to the last user.
  int get currentProfilIndex => _data.getInt(_CURRENT_PROFIL_KEY);

  /// Containes information about the next to use id when creating a new profil.
  /// This is realized, by counting up by one, whenever a new profil is created.
  /// Just using the length of all profiles and adding one to it can result in
  /// various issues when profiles get deleted.
  int get profilesIndex => _data.getInt(_PROFILES_INDEX_KEY);

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

    _data = await SharedPreferences.getInstance();
    if (!_data.containsKey(_PROFILES_INDEX_KEY)) {
      await _data.setInt(_PROFILES_INDEX_KEY, 1);
    }
    if (!_data.containsKey(_CURRENT_PROFIL_KEY)) {
      await _data.setInt(_CURRENT_PROFIL_KEY, 0);
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
        $MAX_SPEED_COLUMN INTEGER,
        $MAX_LIHGT_BRIGHTNESS_COLUMN REAL,

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
    await _data.setInt(_PROFILES_INDEX_KEY, profilesIndex + 1);
    await _db.insert(_TABLE, profil.toMap());
  }

  /// Returns a list of all profiles.
  Future<List<Map<String, Object>>> getProfilesList() async {
    return await _db.query(_TABLE);
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
    await _data.setInt(_CURRENT_PROFIL_KEY, id);
  }

  /// Deletes the profil data at the given [id].
  Future deleteProfil(int id) async {
    await _db.delete(_TABLE, where: '$ID_COLUMN = ?', whereArgs: [id]);
  }
}
