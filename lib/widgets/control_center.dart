import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/lights_provider.dart';

class ControlCenter extends StatefulWidget {
  @override
  _ControlCenterState createState() => _ControlCenterState();
}

class _ControlCenterState extends State<ControlCenter> {
  LightState state = LightState.off;

  void _toggleCruiseControl() {
    // TODO: Implement
  }

  void _hoot() {
    // TODO: Implement
  }

  void _lock() {
    //TODO: Implement
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double height = constraints.maxWidth / 2;
        return SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: ControlCenterLightSwitch(
                    onPressed: () {
                      if (state != LightState.off) {
                        setState(() {
                          state == LightState.on
                              ? state = LightState.dimmed
                              : state = LightState.on;
                        });
                      }
                    },
                    onLongPress: () {
                      setState(() {
                        state == LightState.off
                            ? state = LightState.dimmed
                            : state = LightState.off;
                      });
                    },
                    state: state,
                    icon: EvaIcons.sunOutline,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ControlCenterButton(
                          onPressed: _hoot,
                          icon: EvaIcons.volumeDownOutline,
                        ),
                      ),
                      Expanded(
                        child: AnimatedCrossFade(
                          duration: Duration(milliseconds: 400),
                          crossFadeState: state == LightState.on
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: ControlCenterButton(
                            onPressed: _toggleCruiseControl,
                            icon: EvaIcons.arrowheadRightOutline,
                            selected: false, //TODO: Add Provider data
                          ),
                          secondChild: ControlCenterButton(
                            onPressed: _lock,
                            icon: EvaIcons.lockOutline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ControlCenterLightSwitch extends StatelessWidget {
  final Function onPressed;
  final Function onLongPress;
  final IconData icon;
  final LightState state;
  final EdgeInsets margin;
  final EdgeInsets padding;

  ControlCenterLightSwitch({
    @required this.onPressed,
    @required this.onLongPress,
    @required this.icon,
    this.state: LightState.off,
    this.margin: const EdgeInsets.all(6.0),
    this.padding: const EdgeInsets.all(8.0),
  });

  Color _highlightColor(BuildContext context) {
    if (state != LightState.off) return Theme.of(context).backgroundColor;
    return Theme.of(context).iconTheme.color;
  }

  Color _backgroundColor(BuildContext context) {
    if (state == LightState.on) return Theme.of(context).accentColor;
    if (state == LightState.dimmed)
      return Theme.of(context).accentColor.withOpacity(0.7);
    return Theme.of(context).canvasColor;
  }

  String _text() {
    // TODO: Localization
    if (state == LightState.on) return "An";
    if (state == LightState.dimmed) return "Gedimmt";
    return "Aus";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: margin,
        child: Material(
          borderRadius: BorderRadius.circular(AppTheme.customBorderRadius),
          color: _backgroundColor(context),
          child: InkWell(
            onTap: onPressed,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(AppTheme.customBorderRadius),
            child: Padding(
              padding: padding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    icon,
                    size: 36,
                    color: _highlightColor(context),
                  ),
                  Text(
                    _text(),
                    style: Theme.of(context).textTheme.body1.copyWith(
                          color: _highlightColor(context),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ControlCenterButton extends StatelessWidget {
  final Function onPressed;
  final IconData icon;
  final bool selected;
  final EdgeInsets margin;
  final EdgeInsets padding;

  ControlCenterButton({
    @required this.onPressed,
    @required this.icon,
    this.selected: false,
    this.margin: const EdgeInsets.all(6.0),
    this.padding: const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: margin,
        child: Material(
          borderRadius: BorderRadius.circular(AppTheme.customBorderRadius),
          color: selected
              ? Theme.of(context).accentColor
              : Theme.of(context).canvasColor,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppTheme.customBorderRadius),
            child: Padding(
              padding: padding,
              child: Icon(
                icon,
                size: 36,
                color: selected
                    ? Theme.of(context).backgroundColor
                    : Theme.of(context).iconTheme.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
