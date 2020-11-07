import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';

const String _lightMapPath = "/home/pi/data/map_light/{z}/{x}/{y}.png";
const String _darkMapPath = "/home/pi/data/map_dark/{z}/{x}/{y}.png";

final _home = LatLng(48.5268, 8.5642);

final mapOptions = MapOptions(
  center: _home,
  zoom: 14.0,
  minZoom: 11.0,
  maxZoom: 18.00,
  swPanBoundary: LatLng(48.4932, 8.2804),
  nePanBoundary: LatLng(48.5824, 8.8967),
);

class MapProvider extends ChangeNotifier {
  MapController controller = MapController();

  void toHome() {
    controller.move(_home, 14.0);
  }

  /// Returns the path to the map data based on the theme.
  String mapPath(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) return _darkMapPath;
    return _lightMapPath;
  }
}
