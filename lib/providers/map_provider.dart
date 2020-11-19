import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:kart_project/models/location.dart';
import 'package:kart_project/models/profil.dart';
import 'package:kart_project/providers/profil_provider/profil_provider.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

const String _lightMapPath = "/home/pi/data/map_light/{z}/{x}/{y}.png";
const String _darkMapPath = "/home/pi/data/map_dark/{z}/{x}/{y}.png";

final _home = Location(zoom: 14.0, coordinates: LatLng(48.5268, 8.5642));

final mapOptions = MapOptions(
  center: _home.coordinates,
  zoom: _home.zoom,
  minZoom: 11.0,
  maxZoom: 18.00,
  swPanBoundary: LatLng(48.4932, 8.2804),
  nePanBoundary: LatLng(48.5824, 8.8967),
);

class MapProvider extends ChangeNotifier {
  MapController controller = MapController();
  Location location1;
  Location location2;

  /// Sets and updates the location values based on the [index]. Only updates
  /// its listeners if there is a change.
  void _setLocation(int index, Location location) {
    if (location != _locationOfIndex(index)) {
      if (index == 1) location1 = location;
      if (index == 2) location2 = location;
      // TODO: How to update; even needed?
    }
  }

  /// Updates the location values to the current bounds. The [index] defines if
  /// [location1] or [location2] should be used.
  Future setCurrentLocation(BuildContext context, int index) async {
    // TODO: Add confirmation notification
    Location location = Location(
      zoom: controller.zoom,
      coordinates: controller.center,
    );
    _setLocation(index, location);
    await Provider.of<ProfilProvider>(context, listen: false)
        .setLocation(index, location);
  }

  /// Moves the map to the given [location].
  void _moveToLocation(Location location) {
    controller.move(location.coordinates, location.zoom);
  }

  /// Moves the map to the [_home] location.
  void toHome() {
    _moveToLocation(_home);
  }

  /// Moves to [location1] or [location2] based on the [index].
  void toLocation(int index) {
    // TODO: if location is null
    _moveToLocation(_locationOfIndex(index));
  }

  /// Sets the location values to the ones of the [profil]. Gets normally
  /// called when the profil has changed.
  void updateLocationsWithProfil(Profil profil) {
    _setLocation(1, profil.location1);
    _setLocation(2, profil.location2);
  }

  /// Returns the path to the mapdata based on the theme.
  String mapPath(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) return _darkMapPath;
    return _lightMapPath;
  }

  /// Returns [location1] or [location2] based on the [index].
  Location _locationOfIndex(int index) {
    if (!(index == 1 || index == 2)) {
      throw ArgumentError("Index must be 1 or 2.");
    }
    if (index == 1) return location1;
    return location2;
  }
}
