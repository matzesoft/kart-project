import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/loading_interface.dart';
import 'package:kart_project/design/sized_alert_dialog.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/appearance_provider.dart';
import 'package:kart_project/providers/boot_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/extensions.dart';

class ControlCenter extends StatefulWidget {
  @override
  _ControlCenterState createState() => _ControlCenterState();
}

class _ControlCenterState extends State<ControlCenter> {
  void toggleCruiseControl() async {
    // TODO: Implement
  }

  void hoot() async {
    // TODO: Implement
  }

  void powerOptions() {
    showDialog(
      context: context,
      builder: (context) => BootOptionsDialog(),
    );
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
                          onPressed: powerOptions,
                          icon: EvaIcons.powerOutline,
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
  AppearanceProvider _appearance;
  LightState state;

  void onPress() {
    if (state != LightState.off) {
      state == LightState.on
          ? _appearance.setLightState(LightState.dimmed)
          : _appearance.setLightState(LightState.on);
    }
  }

  void onLongPress() {
    state == LightState.off
        ? _appearance.setLightState(LightState.dimmed)
        : _appearance.setLightState(LightState.off);
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
    _appearance = context.watch<AppearanceProvider>();
    state = _appearance.lightState;
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

class BootOptionsDialog extends StatefulWidget {
  @override
  _BootOptionsDialogState createState() => _BootOptionsDialogState();
}

class _BootOptionsDialogState extends State<BootOptionsDialog> {
  /// Set to true when work is in progress. Normaly used to check wether to show
  /// a [LoadingInterface] or not.
  bool _processing = false;

  void lock(BuildContext context) {
    context.read<BootProvider>().lock();
    Navigator.pop(context);
  }

  Future powerOff(BuildContext context) async {
    setState(() {
      _processing = true;
    });
    await context.read<BootProvider>().powerOff(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_processing) {
      return LoadingInterface(
        message: Strings.turningOff,
      ).dialogInterface();
    }
    return SizedAlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BootOption(
            title: Strings.lock,
            icon: EvaIcons.lockOutline,
            onTap: () {
              lock(context);
            },
          ),
          _BootOption(
            title: Strings.powerOff,
            icon: EvaIcons.powerOutline,
            onTap: () {
              powerOff(context);
            },
          ),
        ],
      ),
    );
  }
}

class _BootOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onTap;

  _BootOption({this.title, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(icon),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(title),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
