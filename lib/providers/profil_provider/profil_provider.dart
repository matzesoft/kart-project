import 'package:flutter/widgets.dart';
import 'package:kart_project/models/location.dart';
import 'package:kart_project/models/profil.dart';
import 'package:kart_project/providers/profil_provider/profil_database.dart';
import 'package:kart_project/strings.dart';

/// Manages the database and gives options to control the profiles.
class ProfilProvider extends ChangeNotifier {
  ProfilDatabase _db = ProfilDatabase();

  /// Indicates if the database is up and running and initalizing has been
  /// finished.
  bool initalized = false;

  /// List of all profiles.
  List<Profil> profiles;

  /// Returns the current profil.
  Profil get currentProfil {
    return profiles.firstWhere(
      (profil) => profil.id == _db.currentProfilIndex,
    );
  }

  ProfilProvider() {
    _init();
  }

  /// Initalizes the database.
  Future _init() async {
    await _db.initDatabase();
    await _updateProfilesList();
    initalized = true;
    notifyListeners();
  }

  /// Updates the [profiles] proberty.
  Future _updateProfilesList() async {
    List<Map> query = await _db.getProfilesList();
    profiles = List.generate(
      query.length,
      (index) => Profil.fromMap(query.elementAt(index)),
    );
  }

  /// Updates the settings of the profil.
  Future _updateProfil(int id, Map<String, Object> values) async {
    await _db.updateProfil(id, values);
    await _updateProfilesList();
    notifyListeners();
  }

  /// Sets the new profil.
  Future setProfil(int id) async {
    await _db.setProfil(id);
    notifyListeners();
  }

  /// Creates a profil with the default settings and switches to it.
  /// If [name] is null, a default name with the profilId will be created.
  Future createProfil({String name}) async {
    print("Called create profil");
    int profilId = _db.profilesIndex;
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
    await _db.createProfil(profil);
    await _updateProfilesList();
    await setProfil(profilId);
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
    _db.deleteProfil(id);
    await _updateProfilesList();
    await setProfil(profiles[0].id);
  }

  /// Updates the name of the profil.
  Future setName(int id, String name) async {
    if (name == null || name.isEmpty)
      throw ArgumentError("Name must not be null or empty.");
    await _updateProfil(id, <String, Object>{nameColumn: name});
  }

  Future setLocation(int index, Location location) async {
    await _updateProfil(currentProfil.id, location.toProfilMap(index));
  }
}
