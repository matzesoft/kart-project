import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/providers/profil_provider.dart';
import 'package:map/map.dart' hide Map;
import 'package:kart_project/extensions.dart';
import 'package:kart_project/strings.dart';
import 'package:latlng/latlng.dart';
import 'package:flutter/widgets.dart';

const _LIGHT_MAP_PATH = "/home/pi/data/map/map_light";
const String _DARK_MAP_PATH = "/home/pi/data/map/map_dark";

final _home = Location(zoom: 14.0, coordinates: LatLng(48.5268, 8.5642));

final _minZoom = 11.00;
final _maxZoom = 18.99;
final _nePanBoundary = LatLng(48.7824, 9.0967);
final _swPanBoundary = LatLng(48.2932, 8.0804);

class MapProvider extends ChangeNotifier {
  final controller = MapController(location: _home.coordinates);
  Profil _profil;

  MapProvider(BuildContext context) {
    _profil = context.profil();
  }

  /// Updates the [MapProvider] with the data of the [newProfil] and returns the
  /// object back. This is normally called inside a [ProxyProvider]s update method.
  MapProvider update(Profil newProfil) {
    _profil = newProfil;
    notifyListeners();

    return this;
  }

  Location get location1 => _profil.location1;
  set location1(Location location) => _profil.location1 = location;

  Location get location2 => _profil.location2;
  set location2(Location location) => _profil.location2 = location;

  /// Sets and updates the location values based on the [index]. Only updates
  /// its listeners if there is a change and [notify] is set to true.
  void _setLocation(int index, Location location) {
    if (index == 1) location1 = location;
    if (index == 2) location2 = location;
  }

  /// Updates the location values to the current bounds. The [index] defines if
  /// [location1] or [location2] should be used.
  void setCurrentLocation(BuildContext context, int index) {
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
    } catch (error) {
      context.showExceptionNotification(Strings.failedSettingLocation);
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
    String path = _LIGHT_MAP_PATH;
    if (Theme.of(context).brightness == Brightness.dark) path = _DARK_MAP_PATH;
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
}

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

  /// Returns the data in form of a map, with the syntax of the [ProfilsSQLHelper].
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

  /// Converts the data from a map with the [ProfilsSQLHelper] syntax.
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
