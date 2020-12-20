import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:kart_project/models/location.dart';
import 'package:kart_project/models/profil.dart';
import 'package:kart_project/providers/profil_provider/profil_database.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/extensions.dart';

/// Lets you create, update and delete profiles.
///
/// Only calls its listeners if the profil is switched. If there are changes to
/// the values in the DB, [notifyListeners] will only be called if the changes
/// are about the profil directely. For example the name of the profil.
///
/// Because the providers using the profil data are also saving theier values in
/// own local variables, it would be unnecessary to call the listeners by the
/// provider itself and the [ProfilProvider].
class ProfilProvider extends ChangeNotifier {
  final ProfilDatabase _db = ProfilDatabase();

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

  /// Updates the settings of the profil. Does NOT call [notifyListeners]!
  Future _updateProfil(Map<String, Object> values) async {
    await _db.updateProfil(currentProfil.id, values);
    await _updateProfilesList();
  }

  /// Sets the new profil.
  Future setProfil(int id) async {
    await _db.setProfil(id);
    notifyListeners();
  }

  /// Creates a profil with the default settings and switches to it.
  /// If [name] is null, a default name with the profilId will be created.
  Future createProfil(BuildContext context, {String name}) async {
    try {
      int profilId = _db.profilesIndex;
      if (name == null || name.isEmpty) {
        name = "${Strings.profil} $profilId";
      }
      Profil profil = Profil(profilId, name: name);
      await _db.createProfil(profil);
      await _updateProfilesList();
      await setProfil(profilId);
      context.showNotification(
        icon: EvaIcons.plusOutline,
        message: Strings.profilWasCreated,
      );
    } catch (error) {
      context.showErrorNotification(Strings.failedCreatingProfil);
    }
  }

  /// Deletes the profil. Throws an [StateError] if there are no other profiles. Switches to the
  /// first profil in the list, if requested profil is the currentUser.
  Future deleteProfil(BuildContext context) async {
    if (profiles.length <= 1) {
      throw StateError("Deleting all profiles is not supported.");
    }
    try {
      await _db.deleteProfil(currentProfil.id);
      await _updateProfilesList();
      await setProfil(profiles[0].id);
      context.showNotification(
        icon: EvaIcons.trash2Outline,
        message: Strings.profilWasDeleted,
      );
    } catch (error) {
      context.showErrorNotification(Strings.failedDeletingProfil);
    }
  }

  /// Updates the name of the profil.
  Future setName(BuildContext context, String name) async {
    if (name == null || name.isEmpty) {
      throw ArgumentError("Name must not be null or empty.");
    }
    try {
      await _updateProfil(<String, Object>{nameColumn: name});
      notifyListeners();
      context.showNotification(
        icon: EvaIcons.personOutline,
        message: Strings.profilWasUpdated,
      );
    } catch (error) {
      context.showErrorNotification(Strings.failedUpdatingProfil);
    }
  }

  Future setThemeMode(int themeMode) async {
    await _updateProfil({themeModeColumn: themeMode});
  }

  Future setMaxLightBrightness(double brightness) async {
    await _updateProfil({maxLightBrightnessColumn: brightness});
  }

  /// Updates the location at the given [index].
  Future setLocation(int index, Location location) async {
    await _updateProfil(location.toProfilMap(index));
  }
}
