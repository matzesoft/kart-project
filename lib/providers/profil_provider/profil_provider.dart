import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:kart_project/providers/map_provider.dart';
import 'package:kart_project/providers/profil_provider/profil_database.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/extensions.dart';

enum ProfilsState {
  notInitalized,
  initalized,
  failedToLoadDB,
}

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
  List<Profil> _profiles;
  ProfilsState _state = ProfilsState.notInitalized;

  /// List of all profiles.
  List<Profil> get profiles => _profiles;

  /// Indicates if the database is up and running and initalizing has been
  /// finished.
  ProfilsState get state => _state;

  /// Returns the current profil.
  Profil get currentProfil {
    return profiles.firstWhere(
      (profil) => profil.id == _db.currentProfilIndex,
    );
  }

  ProfilProvider() {
    _init();
  }

  /// Initalizes the database. Sets [state] to [ProfilsState.failedToLoadDB] if
  /// database crashed.
  Future _init() async {
    Profil._controller = this;
    try {
      await _db.initDatabase();
      await _updateProfilesList();
      _state = ProfilsState.initalized;
    } catch (error) {
      _state = ProfilsState.failedToLoadDB;
    } finally {
      notifyListeners();
    }
  }

  /// Updates the [profiles] proberty.
  /// This method should be removed because profil should update its instances
  /// by itsself.
  @deprecated
  Future _updateProfilesList() async {
    List<Map> query = await _db.getProfilesList();
    _profiles = List.generate(
      query.length,
      (index) => Profil.fromMap(query.elementAt(index)),
    );
  }

  /// Updates the settings of the profil. Only notifys listeners when [notify]
  /// is true.
  Future _updateProfil(Map<String, Object> values, {bool notify: false}) async {
    await _db.updateProfil(currentProfil.id, values);
    await _updateProfilesList();
    if (notify) notifyListeners();
  }

  /// Sets the new profil.
  Future setProfil(BuildContext context, int id) async {
    await _db.setProfil(id).catchError((error) {
      context.showErrorNotification(Strings.failedSettingProfil);
    });
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
      await setProfil(context, profilId);
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
      await setProfil(context, profiles[0].id);
      context.showNotification(
        icon: EvaIcons.trash2Outline,
        message: Strings.profilWasDeleted,
      );
    } catch (error) {
      context.showErrorNotification(Strings.failedDeletingProfil);
    }
  }
}

/// Indicates one Profil. For more information on the specific values check out
/// the assosiated providers.
class Profil {
  static ProfilProvider _controller;
  int id;
  String name;
  int themeMode;
  int maxSpeed;
  double maxLightBrightness;
  String lightStripColor;
  Location location1;
  Location location2;

  Profil(
    this.id, {
    this.name: "Standard Profil",
    this.themeMode: 1,
    this.maxSpeed: 80,
    this.maxLightBrightness: 0.6,
    this.location1,
    this.location2,
  });

  Future setName(BuildContext context, String name) async {
    if (name == null || name.isEmpty) {
      throw ArgumentError("Name must not be null or empty.");
    }
    try {
      await _controller._updateProfil(
        <String, Object>{NAME_COLUMN: name},
        notify: true,
      );
      context.showNotification(
        icon: EvaIcons.personOutline,
        message: Strings.profilWasUpdated,
      );
    } catch (error) {
      context.showErrorNotification(Strings.failedUpdatingProfil);
    }
  }

  Future setThemeMode(int themeMode) async {
    await _updateDatabase({THEME_MODE_COLUMN: themeMode});
  }

  Future setMaxLightBrightness(double brightness) async {
    await _updateDatabase({MAX_LIHGT_BRIGHTNESS_COLUMN: brightness});
  }

  Future setLocation(Map<String, dynamic> location) async {
    await _updateDatabase(location);
  }

  Future setLightStripColor(String color) async {
    await _updateDatabase({LIGHT_STRIP_COLOR_COLUMN: color});
  }

  Future _updateDatabase(Map<String, Object> data) async {
    await _controller._updateProfil(data);
  }

  Map<String, Object> toMap() {
    var data = <String, Object>{
      ID_COLUMN: id,
      NAME_COLUMN: name,
      THEME_MODE_COLUMN: themeMode,
      MAX_LIHGT_BRIGHTNESS_COLUMN: maxLightBrightness,
      LIGHT_STRIP_COLOR_COLUMN: lightStripColor,
      // Locations
    };
    if (location1 != null) data.addAll(location1.toProfilMap(1));
    if (location2 != null) data.addAll(location2.toProfilMap(2));
    return data;
  }

  Profil.fromMap(Map<String, dynamic> profil) {
    id = profil[ID_COLUMN];
    name = profil[NAME_COLUMN];
    themeMode = profil[THEME_MODE_COLUMN];
    maxLightBrightness = profil[MAX_LIHGT_BRIGHTNESS_COLUMN];
    lightStripColor = profil[LIGHT_STRIP_COLOR_COLUMN];
    location1 = Location.fromProfilMap(1, profil);
    location2 = Location.fromProfilMap(2, profil);
  }
}
