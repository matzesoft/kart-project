import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:kart_project/models/location.dart';
import 'package:kart_project/models/profil.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/providers/profil_provider/profil_provider.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/strings.dart';
import 'package:latlong/latlong.dart';

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

  MapProvider(BuildContext context) {
    Profil profil = context.profil().currentProfil;
    _updateLocationsWithProfil(profil);
  }

  /// Updates the [MapProvider] with the data of the [profil] and returns the
  /// object back. This is normally called inside a [ProxyProvider]s update method.
  /// Does update all listeners.
  MapProvider update(Profil profil) {
    _updateLocationsWithProfil(profil);
    notifyListeners();
    return this;
  }

  /// Sets and updates the location values based on the [index]. Only updates
  /// its listeners if there is a change and [notify] is set to true.
  void _setLocation(int index, Location location, {bool notify: true}) {
    if (!location.compare(_locationOfIndex(index))) {
      if (index == 1) location1 = location;
      if (index == 2) location2 = location;
      if (notify) notifyListeners();
    }
  }

  /// Updates the location values to the current bounds. The [index] defines if
  /// [location1] or [location2] should be used.
  Future setCurrentLocation(BuildContext context, int index) async {
    context.read<NotificationsProvider>().showConfirmNotification(
          icon: EvaIcons.pinOutline,
          message: Strings.locationWasSaved,
        );
    Location location = Location(
      zoom: controller.zoom,
      coordinates: controller.center,
    );
    _setLocation(index, location);
    await context.read<ProfilProvider>().setLocation(index, location);
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
  void toLocation(BuildContext context, int index) {
    Location location = _locationOfIndex(index);
    if (location == null) {
      // TODO: Add notification
    } else {
      _moveToLocation(location);
    }
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

  /// Sets the location values to the ones of the [profil]. Gets normally
  /// called when the profil has changed. Does not update any listeners.
  void _updateLocationsWithProfil(Profil profil) {
    _setLocation(1, profil.location1, notify: false);
    _setLocation(2, profil.location2, notify: false);
  }
}
