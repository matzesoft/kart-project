import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/card_with_title.dart';
import 'package:kart_project/providers/temperature_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:provider/provider.dart';

class SafetySetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BatterySafety(),
        SwitchCabinetSafety(),
      ],
    );
  }
}

class SafetyElement extends StatelessWidget {
  SafetyElement({
    required this.icon,
    required this.title,
    required this.message,
    this.level: 0,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String message;
  final int level;
  final Widget child;

  Color primaryColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      if (level == 0) return Colors.green.shade700;
      if (level == 1) return Colors.orange.shade700;
      if (level >= 2) return Colors.red.shade700;
    } else {
      if (level == 0) return Colors.green.shade300;
      if (level == 1) return Colors.orange.shade300;
      if (level >= 2) return Colors.red.shade300;
    }
    return Theme.of(context).canvasColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Icon(icon, color: primaryColor(context)),
            title: Text(
              title,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: primaryColor(context),
                  ),
            ),
            subtitle: Text(message),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.topLeft,
          child: this.child,
        ),
      ],
    );
  }
}

class BatterySafety extends StatelessWidget {
  Widget element(String topic, dynamic data) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Text("$topic: $data°C"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: Strings.battery,
      child: Consumer<TemperatureProvider>(
        builder: (context, temperatureProvider, _) {
          final batteryTemp = temperatureProvider.battery;
          final state = batteryTemp.state;
          final icon = state.level == 0
              ? EvaIcons.checkmarkCircle2Outline
              : state.asErrorNotification.icon;
          final title = state.level == 0
              ? Strings.everythingSafe
              : state.asErrorNotification.title;
          final message = state.level == 0
              ? Strings.batteryTempOk
              : state.asErrorNotification.message;

          return SafetyElement(
            icon: icon,
            title: title,
            message: message,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                element(Strings.batteryTempAverage, batteryTemp.averageTemp),
                element(Strings.batteryTempMax, batteryTemp.maxTemp),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SwitchCabinetSafety extends StatelessWidget {
  Widget element(String topic, dynamic data) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Text("$topic: $data°C"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: Strings.switchCabinet,
      child: Consumer<TemperatureProvider>(
        builder: (context, temperatureProvider, _) {
          final switchCabinetTemp = temperatureProvider.switchCabinet;
          final heatWarningShown = switchCabinetTemp.heatWarningShown;
          final icon = !heatWarningShown
              ? EvaIcons.checkmarkCircle2Outline
              : switchCabinetTemp.heatWarning.icon;
          final title = !heatWarningShown
              ? Strings.everythingSafe
              : switchCabinetTemp.heatWarning.title;
          final message = !heatWarningShown
              ? Strings.swtichCabinetTempOk
              : switchCabinetTemp.heatWarning.message;

          return SafetyElement(
            icon: icon,
            title: title,
            message: message,
            level: heatWarningShown ? 1 : 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                element(
                  Strings.motorControllerTemp,
                  switchCabinetTemp.controllerTemp,
                ),
                element(
                  Strings.switchCabinetTemp,
                  switchCabinetTemp.sensorTemp,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
