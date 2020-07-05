import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class Entertainment extends StatefulWidget {
  @override
  _EntertainmentState createState() => _EntertainmentState();
}

class _EntertainmentState extends State<Entertainment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(56.704173, 11.543808),
          minZoom: 12.0,
          maxZoom: 14.0,
          zoom: 13.0,
          swPanBoundary: LatLng(56.6877, 11.5089),
          nePanBoundary: LatLng(56.7378, 11.6644),
        ),
        layers: [
          TileLayerOptions(
            tileProvider: AssetTileProvider(),
            maxZoom: 14.0,
            urlTemplate: 'assets/map/anholt_osmbright/{z}/{x}/{y}.png',
          ),
        ],
      ),
    );
  }
}
