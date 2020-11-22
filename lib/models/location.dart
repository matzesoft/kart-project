import 'package:flutter/widgets.dart';
import 'package:kart_project/providers/profil_provider/profil_database.dart';
import 'package:latlong/latlong.dart';

/// Takes a [zoom] level and coordinates of a location.
class Location {
  double zoom;
  LatLng coordinates;

  Location({@required this.zoom, @required this.coordinates});

  /// Compares two locations and returns true if they are the same.
  /// In some conditions the default `==`-operator might not work so you can use
  /// this method.
  bool compare(Location second) {
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
        location2ZoomColumn: zoom,
        location2LatColumn: coordinates.latitude,
        location2LngColumn: coordinates.longitude,
      };
    }
    return <String, Object>{
      location1ZoomColumn: zoom,
      location1LatColumn: coordinates.latitude,
      location1LngColumn: coordinates.longitude,
    };
  }

  /// Converts the data from a map with the [ProfilDatabase] syntax.
  Location.fromProfilMap(int index, Map<String, Object> profil) {
    if (!(index == 1 || index == 2)) {
      throw ArgumentError("Index must be 1 or 2.");
    }
    if (index == 1) {
      if (profil[location1ZoomColumn] != null) {
        zoom = profil[location1ZoomColumn];
      }
      if ((profil[location1LatColumn] != null) &&
          (profil[location1LngColumn] != null)) {
        coordinates = LatLng(
          profil[location1LatColumn],
          profil[location1LngColumn],
        );
      }
    } else {
      if (profil[location2ZoomColumn] != null)
        zoom = profil[location2ZoomColumn];
      if ((profil[location2LatColumn] != null) &&
          (profil[location2LngColumn] != null)) {
        coordinates = LatLng(
          profil[location2LatColumn],
          profil[location2LngColumn],
        );
      }
    }
  }
}
