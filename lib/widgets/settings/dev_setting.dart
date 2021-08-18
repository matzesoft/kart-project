import 'dart:async';
import 'dart:io';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/card_with_title.dart';
import 'package:kart_project/providers/motor_controller_provider.dart';
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
            MotorControllerPower(),
            Logs(),
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
            onPressed: () => devOptions.createTestError(context),
          ),
          TextButton(
            child: Text("Close Testerror"),
            onPressed: () => devOptions.closeTestError(context),
          ),
        ],
      ),
    );
  }
}

class MotorControllerPower extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final motorController = context.read<MotorControllerProvider>();

    return CardWithTitle(
      title: "Motor PowerOff",
      child: Column(
        children: [
          TextButton(
            child: Text("Power OFF"),
            onPressed: () => motorController.setPower(false),
          ),
          TextButton(
            child: Text("Power ON"),
            onPressed: () => motorController.setPower(true),
          ),
        ],
      ),
    );
  }
}

class Logs extends StatelessWidget {
  final logDir = Directory("/home/pi/logs/");

  Future<List<FileSystemEntity>> getAllLogs() {
    final files = <FileSystemEntity>[];
    final completer = Completer<List<FileSystemEntity>>();
    logDir.list().listen(
          (file) => files.add(file),
          onDone: () => completer.complete(files),
        );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: "Logs",
      child: FutureBuilder<List<FileSystemEntity>>(
        future: getAllLogs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("Loading logs...");
          final logs = snapshot.data;

          return Column(
            children: List.generate(
              logs!.length,
              (index) {
                return ListTile(
                  title: Text(logs[index].path),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Scaffold(
                            appBar: AppBar(),
                            body: FutureBuilder<String>(
                              future: (logs[index] as File).readAsString(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData)
                                  return Text("Loading log...");
                                return SingleChildScrollView(
                                    child: Text(snapshot.data!));
                              },
                            ),
                          );
                        },
                        fullscreenDialog: true,
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
