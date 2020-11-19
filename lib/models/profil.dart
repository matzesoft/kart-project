import 'package:kart_project/models/location.dart';
import 'package:kart_project/providers/profil_provider/profil_database.dart';

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
  Location location1;
  Location location2;

  Profil({
    this.id,
    this.name,
    this.themeMode,
    this.maxSpeed,
    this.lightBrightness,
    this.location1,
    this.location2,
  });

  Map<String, Object> toMap() {
    var data = <String, Object>{
      idColumn: id,
      nameColumn: name,
      themeModeColumn: themeMode,
      maxSpeedColumn: maxSpeed,
      lightBrightnessColumn: lightBrightness,
      // Locations
    };
    if (location1 != null) data.addAll(location1.toProfilMap(1));
    if (location2 != null) data.addAll(location2.toProfilMap(2));
    return data;
  }

  Profil.fromMap(Map<String, dynamic> profil) {
    id = profil[idColumn];
    name = profil[nameColumn];
    themeMode = profil[themeModeColumn];
    maxSpeed = profil[maxSpeedColumn];
    lightBrightness = profil[lightBrightnessColumn];
    location1 = Location.fromProfilMap(1, profil);
    location2 = Location.fromProfilMap(2, profil);
  }
}
