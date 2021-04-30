import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/card_with_title.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:kart_project/interfaces/gpio_interface.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/providers/cooling_provider.dart';
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
            ErrorNotificationsTest(devOptions),
            FanTest(devOptions),
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
  GpioLine k1 = GpioInterface.kellyOff;
  GpioLine blueLight = GpioInterface.ledBlue;

  void toggleK1() {
    k1.toggle();
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
          child: Text("Blue Light"),
          onPressed: () => toggleBlueLight(),
        ),
      ],
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
          FlatButton(
            child: Text("Create Testerror"),
            onPressed: () {
              devOptions.createTestError(context);
            },
          ),
          FlatButton(
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

class FanTest extends StatefulWidget {
  final DeveloperOptions devOptions;

  FanTest(this.devOptions);

  @override
  _FanTestState createState() => _FanTestState();
}

class _FanTestState extends State<FanTest> {
  void onChange(double value) {
    setState(() {
      widget.devOptions.setFanOutput(context, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: "Fan",
      child: Slider(
        value: context.watch<CoolingProvider>().fan.output,
        onChanged: onChange,
      ),
    );
  }
}
