import 'package:flutter/material.dart';
import 'package:kart_project/design/card_with_title.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/providers/appearance_provider.dart';

class AppeareanceSetting extends StatelessWidget {
  // TODO: UI
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CardWithTitle(
          title: "Licht",
          child: Text("Lichteinstellungen "),
        ),
        CardWithTitle(
          title: "Oberfläche",
          child: FlatButton(
            onPressed: () {
              context.read<AppearanceProvider>().setThemeMode(
                    ThemeMode.dark,
                    context: context,
                  ); // TODO: Testing and funtionality
            },
            child: Text("To Dark"),
          ),
        ),
      ],
    );
  }
}
