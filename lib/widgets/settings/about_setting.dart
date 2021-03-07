import 'package:flutter/material.dart';
import 'package:kart_project/design/number_pad.dart';
import 'package:kart_project/providers/system_provider.dart';
import 'package:provider/provider.dart';

class AboutSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text("Enable Dev Options"),
      onPressed: () {
        NumberPadDialog.show(context, onConfirm: (String pin) {
          context.read<SystemProvider>().enableDevOptions(context, pin);
          Navigator.pop(context);
        });
      },
    );
  }
}
