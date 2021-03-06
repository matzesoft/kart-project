import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/card_with_title.dart';
import 'package:kart_project/providers/system_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:provider/provider.dart';

class DevSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SystemProvider>(
      builder: (context, systemProvider, child) {
        if (!systemProvider.devOptionsEnabled) {
          return Center(child: Text(Strings.devOptionsDisabled));
        }

        final devOptions = systemProvider.devOptions;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () => systemProvider.disableDevOptions(context),
                child: Text(Strings.disable),
                style: TextButton.styleFrom(
                  primary: Theme.of(context).errorColor,
                ),
              ),
            ),
            KartServiceEnable(devOptions),
            ErrorNotificationsTest(devOptions),
          ],
        );
      },
    );
  }
}

class KartServiceEnable extends StatelessWidget {
  final DeveloperOptions devOptions;

  KartServiceEnable(this.devOptions);

  void enable() {
    devOptions.enableKartService();
  }

  void disable() {
    devOptions.disableKartService();
  }

  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: Strings.systemdService,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Icon(EvaIcons.checkmarkOutline),
              label: Text(Strings.enable),
              onPressed: enable,
              style: TextButton.styleFrom(padding: EdgeInsets.all(16.0)),
            ),
            TextButton.icon(
              icon: Icon(EvaIcons.closeOutline),
              label: Text(Strings.disable),
              onPressed: disable,
              style: TextButton.styleFrom(padding: EdgeInsets.all(16.0)),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorNotificationsTest extends StatelessWidget {
  final DeveloperOptions devOptions;

  ErrorNotificationsTest(this.devOptions);

  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: "Error Notifications",
      child: Column(
        children: [
          TextButton(
            child: Text("Create Testerror"),
            onPressed: () {
              devOptions.createTestError(context);
            },
          ),
          TextButton(
            child: Text("Close Testerror"),
            onPressed: () {
              devOptions.closeTestError(context);
            },
          ),
        ],
      ),
    );
  }
}
