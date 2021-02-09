import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/audio_provider.dart';
import 'package:kart_project/providers/boot_provider.dart';
import 'package:kart_project/providers/light_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:provider/provider.dart';

class ControlCenter extends StatefulWidget {
  @override
  _ControlCenterState createState() => _ControlCenterState();
}

class _ControlCenterState extends State<ControlCenter> {
  void toggleCruiseControl() async {
    // TODO: Implement
  }

  void hoot() async {
    context.read<AudioProvider>().playHootSound();
  }

  void lock() {
    context.read<BootProvider>().lock();
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
                  child: _LightSwitch(),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: _ControlCenterButton(
                          onPressed: hoot,
                          icon: EvaIcons.volumeDownOutline,
                        ),
                      ),
                      // TODO: Improve transition
                      Expanded(
                        child: _ControlCenterButton(
                          onPressed: lock,
                          icon: EvaIcons.lockOutline,
                        ),
                      ),
                      /*
                      AnimatedCrossFade(
                        duration: Duration(milliseconds: 400),
                        crossFadeState: state == LightState.on
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: Expanded(
                          child: ControlCenterButton(
                            onPressed: _toggleCruiseControl,
                            icon: EvaIcons.arrowheadRightOutline,
                            selected: false, //TODO: Add Provider data
                          ),
                        ),
                        secondChild: Expanded(
                          child: ControlCenterButton(
                            onPressed: _lock,
                            icon: EvaIcons.lockOutline,
                          ),
                        ),
                      ),
                      */
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

class _LightSwitch extends StatefulWidget {
  @override
  _LightSwitchState createState() => _LightSwitchState();
}

class _LightSwitchState extends State<_LightSwitch> {
  LightProvider light;
  LightState state;

  void onPress() {
    if (state != LightState.off) {
      state == LightState.on
          ? light.setLightState(LightState.dimmed)
          : light.setLightState(LightState.on);
    }
  }

  void onLongPress() {
    state == LightState.off
        ? light.setLightState(LightState.dimmed)
        : light.setLightState(LightState.off);
  }

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
    if (state == LightState.on) return Strings.on;
    if (state == LightState.dimmed) return Strings.dimmed;
    return Strings.off;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LightProvider>(
      builder: (context, lightProvider, _) {
        this.light = lightProvider;
        this.state = light.lightState;

        return SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.all(6.0),
            child: Material(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              color: _backgroundColor(context),
              child: InkWell(
                onTap: onPress,
                onLongPress: onLongPress,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        EvaIcons.sunOutline,
                        size: 36,
                        color: _highlightColor(context),
                      ),
                      Text(
                        _text(),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
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
      },
    );
  }
}

class _ControlCenterButton extends StatelessWidget {
  final Function onPressed;
  final IconData icon;
  final bool selected;
  final EdgeInsets margin;
  final EdgeInsets padding;

  _ControlCenterButton({
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
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          color: selected
              ? Theme.of(context).accentColor
              : Theme.of(context).canvasColor,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
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
