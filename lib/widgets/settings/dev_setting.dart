import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/card_with_title.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:kart_project/interfaces/gpio_interface.dart';
import 'package:kart_project/extensions.dart';
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
              child: FlatButton(
                onPressed: () => systemProvider.disableDevOptions(context),
                child: Text(Strings.disable),
                textColor: Theme.of(context).errorColor,
              ),
            ),
            KartServiceEnable(devOptions),
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
            FlatButton.icon(
              icon: Icon(EvaIcons.checkmarkOutline),
              label: Text(Strings.enable),
              onPressed: enable,
              padding: EdgeInsets.all(16.0),
            ),
            FlatButton.icon(
              icon: Icon(EvaIcons.closeOutline),
              label: Text(Strings.disable),
              onPressed: disable,
              padding: EdgeInsets.all(16.0),
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: Implement in DevSettings
class TestGpios extends StatefulWidget {
  @override
  _TestGpiosState createState() => _TestGpiosState();
}

class _TestGpiosState extends State<TestGpios> {
  GpioLine k1 = GpioInterface.eLock;
  GpioLine k2 = GpioInterface.cruise;
  GpioLine blueLight = GpioInterface.ledBlue;

  void toggleK1() {
    k1.toggle();
  }

  void toggleK2() {
    k2.toggle();
  }

  void toggleBlueLight() {
    blueLight.toggle();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FlatButton(
          child: Text("K1"),
          onPressed: () => toggleK1(),
        ),
        FlatButton(
          child: Text("K2"),
          onPressed: () => toggleK2(),
        ),
        FlatButton(
          child: Text("Blue Light"),
          onPressed: () => toggleBlueLight(),
        ),
      ],
    );
  }
}
