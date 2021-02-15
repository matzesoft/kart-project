import 'package:flutter/widgets.dart';
import 'package:kart_project/providers/profil_provider/profil_database.dart';
import 'package:latlng/latlng.dart';

/// Takes a [zoom] level and coordinates of a location.
class Location {
  double zoom;
  LatLng coordinates;

  bool get isNull => (zoom == null && coordinates == null) ? true : false;

  Location({@required this.zoom, @required this.coordinates});

  /// Compares two locations and returns true if they are the same.
  /// In some conditions the default `==`-operator might not work so you can use
  /// this method.
  bool equals(Location second) {
    if (second == null) return false;
    if ((zoom != second.zoom) || (coordinates != second.coordinates)) {
      return false;
    }
    return true;
  }

  /// Returns the data in form of a map, with the syntax of the [ProfilDatabase].
  Map<String, Object> toProfilMap(int index) {
    if (!(index == 1 || index == 2)) {
      throw ArgumentError("Index must be 1 or 2.");
    }
    if (index == 2) {
      return <String, Object>{
        LOCATION2_ZOOM_COLUMN: zoom,
        LOCATION2_LAT_COLUMN: coordinates.latitude,
        LOCATION2_LNG_COLUMN: coordinates.longitude,
      };
    }
    return <String, Object>{
      LOCATION1_ZOOM_COLUMN: zoom,
      LOCATION1_LAT_COLUMN: coordinates.latitude,
      LOCATION1_LNG_COLUMN: coordinates.longitude,
    };
  }

  /// Converts the data from a map with the [ProfilDatabase] syntax.
  Location.fromProfilMap(int index, Map<String, Object> profil) {
    if (!(index == 1 || index == 2)) {
      throw ArgumentError("Index must be 1 or 2.");
    }
    if (index == 1) {
      if (profil[LOCATION1_ZOOM_COLUMN] != null) {
        zoom = profil[LOCATION1_ZOOM_COLUMN];
      }
      if ((profil[LOCATION1_LAT_COLUMN] != null) &&
          (profil[LOCATION1_LNG_COLUMN] != null)) {
        coordinates = LatLng(
          profil[LOCATION1_LAT_COLUMN],
          profil[LOCATION1_LNG_COLUMN],
        );
      }
    } else {
      if (profil[LOCATION2_ZOOM_COLUMN] != null)
        zoom = profil[LOCATION2_ZOOM_COLUMN];
      if ((profil[LOCATION2_LAT_COLUMN] != null) &&
          (profil[LOCATION2_LNG_COLUMN] != null)) {
        coordinates = LatLng(
          profil[LOCATION2_LAT_COLUMN],
          profil[LOCATION2_LNG_COLUMN],
        );
      }
    }
  }
}
