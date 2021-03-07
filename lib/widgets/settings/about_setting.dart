import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/card_with_title.dart';
import 'package:kart_project/design/custom_list_tile.dart';
import 'package:kart_project/design/number_pad.dart';
import 'package:kart_project/providers/system_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:provider/provider.dart';

class AboutSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TheProject(),
        SoftwareInfo(),
      ],
    );
  }
}

class TheProject extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Container(
          width: double.infinity,
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
    );
  }
}

class SoftwareInfo extends StatelessWidget {
  void enableDevOptions(BuildContext context) {
    NumberPadDialog.show(context, onConfirm: (String pin) {
      context.read<SystemProvider>().enableDevOptions(context, pin);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: Strings.software,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomListTile(
              onDoubleTap: () => enableDevOptions(context),
              icon: Icon(EvaIcons.hashOutline),
              title: Strings.version,
              subtitle: SOFTWARE_VERSION,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomListTile(
              icon: Icon(EvaIcons.githubOutline),
              title: Strings.openSourceOnGitHub,
              subtitle: GITHUB_REPO_LINK,
            ),
          ),
        ],
      ),
    );
  }
}
