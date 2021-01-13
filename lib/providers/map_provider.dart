import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:map/map.dart';
import 'package:kart_project/models/location.dart';
import 'package:kart_project/models/profil.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/strings.dart';
import 'package:latlng/latlng.dart';

const String _lightMapPath = "/home/pi/data/map/map_light";
const String _darkMapPath = "/home/pi/data/map/map_dark";

final _home = Location(zoom: 14.0, coordinates: LatLng(48.5268, 8.5642));

final _minZoom = 11.00;
final _maxZoom = 18.99;
final _nePanBoundary = LatLng(48.7824, 9.0967);
final _swPanBoundary = LatLng(48.2932, 8.0804);

class MapProvider extends ChangeNotifier {
  MapController controller = MapController(location: _home.coordinates);
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
    if (!location.equals(_locationOfIndex(index))) {
      if (index == 1) location1 = location;
      if (index == 2) location2 = location;
      if (notify) notifyListeners();
    }
  }

  /// Updates the location values to the current bounds. The [index] defines if
  /// [location1] or [location2] should be used. Informs the user when trying to
  /// save the home coordinates.
  Future setCurrentLocation(BuildContext context, int index) async {
    try {
      Location location = Location(
        zoom: controller.zoom,
        coordinates: controller.center,
      );
      _setLocation(index, location);
      context.showNotification(
        icon: EvaIcons.pinOutline,
        message: Strings.locationWasSaved,
      );
      await context.profil().setLocation(index, location);
    } catch (error) {
      context.showErrorNotification(Strings.failedSettingLocation);
    }
  }

  /// Moves the map to the given [location].
  void _moveToLocation(Location location) {
    controller.center = location.coordinates;
    controller.zoom = location.zoom;
  }

  /// Moves the map to the [_home] location.
  void toHome() {
    _moveToLocation(_home);
  }

  /// Moves to [location1] or [location2] based on the [index].
  void toLocation(BuildContext context, int index) {
    Location location = _locationOfIndex(index);
    if (location.isNull) {
      context.showInformNotification(
        icon: EvaIcons.pinOutline,
        message: Strings.saveLocationExplanation,
      );
    } else {
      _moveToLocation(location);
    }
  }

  /// Increases the zoom level by checking on the [_maxZoom] level.
  void increaseZoomLevel() {
    // TODO: Test
    final newZoom = controller.zoom + 0.03;
    if (newZoom >= _maxZoom) {
      controller.zoom = _maxZoom;
    } else {
      controller.zoom = newZoom;
    }
  }

  /// Decreases the zoom level by checking on the [_minZoom] level.
  void decreaseZoomLevel() {
    final newZoom = controller.zoom - 0.04;
    if (_minZoom >= newZoom) {
      controller.zoom = _minZoom;
    } else {
      controller.zoom = newZoom;
    }
  }

  void dragMap(double x, double y) {
    final center = controller.center;
    if ((center.latitude >= _nePanBoundary.latitude && y > 0) ||
        (center.latitude <= _swPanBoundary.latitude && y < 0)) {
      y = 0;
    }
    if ((center.longitude >= _nePanBoundary.longitude && x < 0) ||
        (center.longitude <= _swPanBoundary.longitude && x > 0)) {
      x = 0;
    }
    controller.drag(x, y);
  }

  /// Returns the path to the mapdata based on the theme.
  String mapPath(BuildContext context, int x, int y, int z) {
    String path = _lightMapPath;
    if (Theme.of(context).brightness == Brightness.dark) path = _darkMapPath;
    path += "/$z/$x/$y.png";
    return path;
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
