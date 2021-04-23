import 'dart:async';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/map_provider.dart';
import 'package:provider/provider.dart';
import 'package:map/map.dart';

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
          MapWidget(),
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
  Timer? _timer;
  String time = "";

  void setClock() {
    time = DateFormat('kk:mm').format(DateTime.now());
  }

  @override
  void initState() {
    setClock();
    _timer = Timer.periodic(Duration(milliseconds: 2000), (_) {
      setState(() {
        setClock();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
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
            LocationButton(
              icon: Icon(EvaIcons.pinOutline),
              onPressed: () {
                mapProvider.toLocation(context, 1);
              },
              onLongPress: () {
                mapProvider.setCurrentLocation(context, 1);
              },
            ),
            LocationButton(
              icon: Icon(EvaIcons.pinOutline),
              onPressed: () {
                mapProvider.toLocation(context, 2);
              },
              onLongPress: () {
                mapProvider.setCurrentLocation(context, 2);
              },
            ),
            LocationButton(
              icon: Icon(EvaIcons.homeOutline),
              onPressed: () {
                mapProvider.toHome();
              },
            ),
          ],
        );
      },
    );
  }
}

class LocationButton extends StatelessWidget {
  final _radius = BorderRadius.circular(90.0);
  final Widget? icon;
  final Function()? onPressed;
  final Function()? onLongPress;

  LocationButton({this.icon, this.onPressed, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: _radius,
        elevation: AppTheme.elevation,
        shadowColor: AppTheme.shadowColor(context),
        color: Theme.of(context).backgroundColor,
        child: InkWell(
          onTap: onPressed,
          onLongPress: onLongPress,
          borderRadius: _radius,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: icon,
          ),
        ),
      ),
    );
  }
}

class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  MapProvider? _mapProvider;
  Offset? _dragStart;
  double _scaleStart = 1.0;

  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final double scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      _mapProvider!.increaseZoomLevel();
    } else if (scaleDiff < 0) {
      _mapProvider!.decreaseZoomLevel();
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart!;
      _dragStart = now;
      _mapProvider!.dragMap(diff.dx, diff.dy);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        _mapProvider = mapProvider;
        return GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          child: Map(
            controller: _mapProvider!.controller,
            builder: (context, x, y, z) {
              return Image.asset(
                mapProvider.mapPath(context, x, y, z),
                fit: BoxFit.cover,
              );
            },
          ),
        );
      },
    );
  }
}

/*
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
*/
