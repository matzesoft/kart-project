import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/custom_list_tile.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/dashboard/control_center.dart';
import 'package:kart_project/widgets/settings/settings.dart';

/// Padding each element/widget should have.
const EdgeInsets widgetPadding =
    EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

/// Shows information about the speed and the consumption and gives
/// contol over the lights and other quick actions.
class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: AppTheme.elevation + 10.0,
      shadowColor: AppTheme.shadowColor(context),
      color: Theme.of(context).backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                SpeedAndProfile(),
                MomentaryConsumption(),
                Battery(),
                Consumption(),
              ],
            ),
            ControlCenter(),
          ],
        ),
      ),
    );
  }
}

class SpeedAndProfile extends StatelessWidget {
  void _openProfilMenu(BuildContext context) {
    Navigator.pushNamed(context, Settings.route);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: widgetPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                "32", // TODO: Add API
                style: Theme.of(context).textTheme.headline1,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 18.0,
                ),
                child: Text(
                  Strings.kmh,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 1,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: IconButton(
              icon: Icon(EvaIcons.settings2Outline),
              iconSize: AppTheme.iconButtonSize,
              onPressed: () {
                _openProfilMenu(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class MomentaryConsumption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widgetPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 10,
            width: double.infinity,
            decoration: ShapeDecoration(
              color: Theme.of(context).canvasColor,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: FractionallySizedBox(
                    widthFactor: 0.0, // TODO: Animate and add API
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(AppTheme.borderRadius),
                            bottomLeft:
                                Radius.circular(AppTheme.borderRadius),
                          ),
                        ),
                      ),
                      height: double.infinity,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FractionallySizedBox(
                    alignment: Alignment.topLeft,
                    widthFactor: 0.6, // TODO: Animate and add API
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight:
                                Radius.circular(AppTheme.borderRadius),
                            bottomRight:
                                Radius.circular(AppTheme.borderRadius),
                          ),
                        ),
                      ),
                      height: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "3 kW", //TODO: Add API
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
        ],
      ),
    );
  }
}

class Battery extends StatefulWidget {
  @override
  _BatteryState createState() => _BatteryState();
}

class _BatteryState extends State<Battery> {
  final Duration _animationDuration = Duration(milliseconds: 300);
  double _batteryPercentageBefore = 1.0;
  double _batteryPercentage = 0.4;

  Color _batteryColor() {
    if (_batteryPercentage <= 0.2) {
      return Colors.red;
    } else if (_batteryPercentage <= 0.35) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widgetPadding,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                width: 55,
                alignment: Alignment.center,
                child: Text(
                  (_batteryPercentage * 100).round().toString() + "%",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              Expanded(
                child: Container(
                  height: 18,
                  decoration: ShapeDecoration(
                    color: Theme.of(context).canvasColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                    ),
                  ),
                  alignment: Alignment.topLeft,
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(
                      begin: _batteryPercentageBefore,
                      end: _batteryPercentage,
                    ),
                    duration: _animationDuration,
                    builder: (context, percentage, child) {
                      return FractionallySizedBox(
                        widthFactor: percentage,
                        child: AnimatedContainer(
                          duration: _animationDuration,
                          decoration: ShapeDecoration(
                            color: _batteryColor(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadius,
                              ),
                            ),
                          ),
                          height: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Consumption extends StatelessWidget {
  void _openConsumptionHistory() {
    // TODO: Implement
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widgetPadding,
      child: Column(
        children: <Widget>[
          CustomListTile(
            icon: Icon(EvaIcons.trendingUpOutline),
            title: "43 km", //TODO: Add API
            subtitle: Strings.range,
            onPressed: _openConsumptionHistory,
            trailing: Icon(EvaIcons.arrowIosForwardOutline),
          ),
        ],
      ),
    );
  }
}
