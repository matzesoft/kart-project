# Using the map data in your own project

Here is how to use the map data of this project in your own `flutter-pi` app.

### Download the data
Extract the Zip and place it and the path you want. The data is on Google Drive and takes about 3.5GB:
https://drive.google.com/file/d/153wxV6dhEK_cmEMHaGnxOh_uefwPiz8W/view?usp=sharing

### Code implementation

Set the `_mapPath` to your map data. In my case my data is saved at the home directory under a data folder.
Add the [`flutter_map`](https://pub.dev/packages/flutter_map) and the [`latlong`](https://pub.dev/packages/latlong) package to your `pupspec.yaml`.
Implement this widget inside of your `flutter-pi` app.

`_mapOptions` holds the options the map data was exported with. Do not change these. They are also described inside the `info.txt` file.

```dart
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';

class MyMap extends StatelessWidget {
  final _mapPath = "/home/pi/data/map/{z}/{x}/{y}.png";

  final _mapOptions = MapOptions(
    center: LatLng(48.5268, 8.5642),
    zoom: 14.0,
    minZoom: 11.0,
    maxZoom: 18.00,
    swPanBoundary: LatLng(48.4932, 8.2804),
    nePanBoundary: LatLng(48.5824, 8.8967),
  );

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: _mapOptions,
      layers: [
        TileLayerOptions(
          tileProvider: FileTileProvider(),
          urlTemplate: _mapPath,
        ),
      ],
    );
  }
}
```