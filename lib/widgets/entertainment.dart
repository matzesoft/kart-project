import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:kart_project/providers/map_provider.dart';
import 'package:provider/provider.dart';

class Entertainment extends StatefulWidget {
  @override
  _EntertainmentState createState() => _EntertainmentState();
}

class _EntertainmentState extends State<Entertainment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Map(),
          Row(
            children: [
              IconButton(
                iconSize: 35,
                icon: Icon(EvaIcons.homeOutline),
                onPressed: () {
                  Provider.of<MapProvider>(context, listen: false).toHome();
                },
              ),
              Text(
                DateTime.now().toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Map extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        return FlutterMap(
          options: mapOptions,
          mapController: mapProvider.controller,
          layers: [
            TileLayerOptions(
              tileProvider: FileTileProvider(),
              urlTemplate: mapProvider.mapPath(context),
            ),
          ],
        );
      },
    );
  }
}
