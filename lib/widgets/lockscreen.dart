import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/loading_interface.dart';
import 'package:kart_project/design/sized_alert_dialog.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/boot_provider.dart';
import 'package:provider/provider.dart';
import 'package:kart_project/strings.dart';

class Lockscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WelcomeMessage(),
        ),
        Expanded(
          child: NumberPad(),
        ),
      ],
    );
  }
}

class WelcomeMessage extends StatelessWidget {
  void _showPowerOffDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => BootOptionsDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(36.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  EvaIcons.navigation,
                  color: Theme.of(context).accentColor,
                  size: 36,
                ),
              ),
              Text(
                Strings.projectName,
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center,
              ),
              Text(
                Strings.projectSlogan,
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
            icon: Icon(EvaIcons.powerOutline),
            iconSize: AppTheme.iconButtonSize,
            onPressed: () {
              _showPowerOffDialog(context);
            },
          ),
        ),
      ],
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

  Future powerOff(BuildContext context) async {
    setState(() {
      _processing = true;
    });
    await context.read<BootProvider>().powerOff(context);
  }

  Future reboot(BuildContext context) async {
    setState(() {
      _processing = true;
    });
    await context.read<BootProvider>().reboot(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_processing) {
      return LoadingInterface(
        message: Strings.poweringOff,
      ).dialogInterface();
    }
    return SizedAlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(height: 8.0), // Needed to set elements in full center
          _BootOption(
            title: Strings.powerOff,
            icon: EvaIcons.powerOutline,
            onTap: () {
              powerOff(context);
            },
          ),
          _BootOption(
            title: Strings.reboot,
            icon: EvaIcons.refreshOutline,
            onTap: () {
              reboot(context);
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
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

class NumberPad extends StatefulWidget {
  @override
  _NumberPadState createState() => _NumberPadState();
}

class _NumberPadState extends State<NumberPad> {
  TextEditingController controller = TextEditingController();

  /// Adds the given number to the [pinInput]. If the [pinInput] is as long as
  /// the requested pin it will be checked. If the pin is wrong [widget.clear] is called.
  void addNumber(int number) {
    controller.text += number.toString();
  }

  /// Removes the last number from the [pinInput].
  void removeNumber() {
    String pinInput = controller.text;
    if (pinInput.length > 0) {
      pinInput = pinInput.substring(0, pinInput.length - 1);
    }
    controller.text = pinInput;
  }

  void unlock() {
    if (!context.read<BootProvider>().unlock(context, controller.text)) {
      controller.clear();
    }
  }

  Widget lockButtonWithText(int index) {
    return _LockButton.withText(
      onTap: () => addNumber(index),
      text: index.toString(),
    );
  }

  /// Creates a row of [_LockButton]. [startPoint] defines the number of the
  /// first item.
  Widget lockButtonRow(int startPoint, {int length: 3}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        length,
        (index) => lockButtonWithText(startPoint + index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          width: 160.0,
          child: TextField(
            readOnly: true,
            controller: controller,
            obscureText: true,
            style: TextStyle(fontSize: 26.0),
            textAlign: TextAlign.center,
          ),
        ),
        Column(
          children: [
            lockButtonRow(7),
            lockButtonRow(4),
            lockButtonRow(1),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LockButton(
              onTap: () => unlock(),
              child: Icon(EvaIcons.checkmarkOutline),
            ),
            lockButtonWithText(0),
            _LockButton(
              onTap: () => removeNumber(),
              child: Icon(EvaIcons.arrowIosBackOutline),
            ),
          ],
        ),
      ],
    );
  }
}

/// Circular button which can be used in numberpads.
class _LockButton extends StatelessWidget {
  static const _borderRadius = 90.0;
  static const _size = 80.0;
  final Function onTap;
  final Widget child;

  _LockButton({this.onTap, this.child});

  _LockButton.withText({this.onTap, String text})
      : child = Text(
          text,
          style: TextStyle(fontSize: 26.0),
        );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: _size,
        width: _size,
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(_borderRadius),
            child: Container(
              padding: EdgeInsets.all(24.0),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
