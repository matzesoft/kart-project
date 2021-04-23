import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

class NumberPad extends StatefulWidget {
  final Function(String) onConfirm;

  NumberPad({required this.onConfirm});

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

  void confirm() {
    widget.onConfirm(controller.text);
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
              onTap: () => confirm(),
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
  static const _BORDER_RADIUS = 90.0;
  static const _SIZE = 80.0;
  final Function()? onTap;
  final Widget? child;

  _LockButton({this.onTap, this.child});

  _LockButton.withText({this.onTap, String text: ""})
      : child = Text(
          text,
          style: TextStyle(fontSize: 26.0),
        );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: _SIZE,
        width: _SIZE,
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(_BORDER_RADIUS),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(_BORDER_RADIUS),
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

/// Implements the [NumberPad] inside a dialog and shows it.
class NumberPadDialog {
  final Function(String) onConfirm;

  NumberPadDialog.show(BuildContext context, {required this.onConfirm}) {
    showDialog(context: context, builder: _build);
  }

  Widget _build(BuildContext context) {
    return AlertDialog(
      content: NumberPad(onConfirm: onConfirm),
    );
  }
}
