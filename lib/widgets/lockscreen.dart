import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/providers/boot_provider.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/strings.dart';

class Lockscreen extends StatefulWidget {
  @override
  _LockscreenState createState() => _LockscreenState();
}

class _LockscreenState extends State<Lockscreen> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
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
        ),
        Expanded(
          child: NumberPad(),
        ),
      ],
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
    return LockButton.withText(
      onTap: () => addNumber(index),
      text: index.toString(),
    );
  }

  /// Creates a row of [LockButton]. [startPoint] defines the number of the
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
            LockButton(
              onTap: () => unlock(),
              child: Icon(EvaIcons.checkmarkOutline),
            ),
            lockButtonWithText(0),
            LockButton(
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
class LockButton extends StatelessWidget {
  static const _borderRadius = 90.0;
  static const _size = 80.0;
  final Function onTap;
  final Widget child;

  LockButton({this.onTap, this.child});

  LockButton.withText({this.onTap, String text})
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
