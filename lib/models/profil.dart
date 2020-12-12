import 'package:kart_project/models/location.dart';
import 'package:kart_project/providers/profil_provider/profil_database.dart';

/// Indicates one Profil. For more information on the specific values check out
/// the assosiated provider.fe
class Profil {
  int id;
  String name;
  int themeMode;
  int maxSpeed;
  double maxLightBrightness;
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

  Map<String, Object> toMap() {
    var data = <String, Object>{
      idColumn: id,
      nameColumn: name,
      themeModeColumn: themeMode,
      maxSpeedColumn: maxSpeed,
      maxLightBrightnessColumn: maxLightBrightness,
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
    maxLightBrightness = profil[maxLightBrightnessColumn];
    location1 = Location.fromProfilMap(1, profil);
    location2 = Location.fromProfilMap(2, profil);
  }
}
