import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/audio_provider.dart';
import 'package:kart_project/providers/motor_controller_provider.dart';
import 'package:kart_project/providers/light_provider.dart';
import 'package:kart_project/providers/system_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:provider/provider.dart';

class ControlCenter extends StatefulWidget {
  @override
  _ControlCenterState createState() => _ControlCenterState();
}

class _ControlCenterState extends State<ControlCenter> {
  void hoot() async {
    context.read<AudioProvider>().playHootSound();
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
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: LowSpeedButton(),
                            ),
                            Expanded(
                              flex: 1,
                              child: LockButton(),
                            ),
                          ],
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

class LowSpeedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MotorControllerProvider>(
      builder: (context, kellyController, _) {
        final lowSpeedMode = kellyController.lowSpeedMode;

        return _ControlCenterButton(
          onPressed: lowSpeedMode.forceLowSpeed
              ? null
              : () {
                  lowSpeedMode.alwaysActive = !lowSpeedMode.alwaysActive;
                },
          icon: EvaIcons.flashOutline,
          selected: lowSpeedMode.isActive,
          accentColor: Theme.of(context).brightness == Brightness.light
              ? Colors.green[700]
              : Colors.green[300],
        );
      },
    );
  }
}

class LockButton extends StatelessWidget {
  void toggleEnableMotor(MotorControllerProvider controller) {
    controller.enableMotor(!controller.motorEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MotorControllerProvider>(
      builder: (context, kellyController, _) {
        final systemProvider = context.read<SystemProvider>();
        final motorLocked = !kellyController.motorEnabled;

        return _ControlCenterButton(
          onPressed: kellyController.allowDisEnableMotor
              ? () => toggleEnableMotor(kellyController)
              : null,
          onLongPress: systemProvider.allowLock(kellyController)
              ? () => systemProvider.lock(kellyController)
              : null,
          selected: motorLocked,
          icon: motorLocked ? EvaIcons.lockOutline : EvaIcons.unlockOutline,
          accentColor: Theme.of(context).brightness == Brightness.light
              ? Colors.red[700]
              : Colors.red[300],
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
  LightProvider? light;
  LightState? state;

  void onPress() {
    if (state != LightState.off) {
      state == LightState.on
          ? light!.lightState = LightState.dimmed
          : light!.lightState = LightState.on;
    }
  }

  void onLongPress() {
    state == LightState.off
        ? light!.lightState = LightState.dimmed
        : light!.lightState = LightState.off;
  }

  Color _highlightColor(BuildContext context) {
    if (state != LightState.off) return Theme.of(context).backgroundColor;
    return Theme.of(context).iconTheme.color!;
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
        this.state = light!.lightState;

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
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
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
  final Function()? onPressed;
  final Function()? onLongPress;
  final IconData icon;
  final bool selected;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Color? accentColor;

  _ControlCenterButton({
    required this.onPressed,
    required this.icon,
    this.selected: false,
    this.onLongPress,
    this.margin: const EdgeInsets.all(6.0),
    this.padding: const EdgeInsets.all(8.0),
    this.accentColor,
  });

  bool get disabled => onPressed == null;

  Color backgroundColor(BuildContext context) {
    final color = selected
        ? (accentColor == null ? Theme.of(context).accentColor : accentColor)
        : Theme.of(context).canvasColor;
    if (disabled) return color!.withAlpha(100);
    return color!;
  }

  Color iconColor(BuildContext context) {
    final Color color = selected
        ? Theme.of(context).backgroundColor
        : Theme.of(context).iconTheme.color!;
    if (disabled) return color.withAlpha(100);
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: margin,
        child: Material(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          color: backgroundColor(context),
          child: InkWell(
            onTap: onPressed,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            child: Padding(
              padding: padding,
              child: Icon(
                icon,
                size: 36,
                color: iconColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
