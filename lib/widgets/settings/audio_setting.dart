import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/card_with_title.dart';
import 'package:kart_project/strings.dart';

class AudioSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AudioStreaming(),
      ],
    );
  }
}

class AudioStreaming extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: Strings.hearMusic,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                isThreeLine: true,
                leading: Icon(EvaIcons.bluetoothOutline),
                title: Text(Strings.connectWithBluetooth),
                subtitle: Text(Strings.connectWithBluetoothExplanation),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                isThreeLine: true,
                leading: Icon(EvaIcons.smartphoneOutline),
                title: Text(Strings.multipleDevices),
                subtitle: Text(Strings.multipleDevicesExplanation),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                isThreeLine: true,
                leading: Icon(EvaIcons.skipForwardOutline),
                title: Text(Strings.musicControl),
                subtitle: Text(Strings.musicControlExplanation),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
