import 'dart:async';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:intl/intl.dart';
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
      floatingActionButton: LocationControls(),
      body: Stack(
        children: [
          Map(),
          Clock(),
        ],
      ),
    );
  }
}

class Clock extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ClockState();
  }
}

class _ClockState extends State<Clock> {
  String time = "";

  void setClock() {
    time = DateFormat('kk:mm').format(DateTime.now());
  }

  @override
  void initState() {
    setClock();
    Timer.periodic(Duration(milliseconds: 2000), (_) {
      setState(() {
        setClock();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.all(8.0),
      child: Text(time),
    );
  }
}

class LocationControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                child: Icon(EvaIcons.pinOutline),
                onPressed: () {
                  mapProvider.toLocation(1);
                },
                onLongPress: () {
                  mapProvider.setCurrentLocation(context, 1);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                child: Icon(EvaIcons.pinOutline),
                onPressed: () {
                  mapProvider.toLocation(2);
                },
                onLongPress: () {
                  mapProvider.setCurrentLocation(context, 2);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                child: Icon(EvaIcons.homeOutline),
                onPressed: () {
                  mapProvider.toHome();
                },
              ),
            ),
          ],
        );
      },
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
