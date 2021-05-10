import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/card_with_title.dart';
import 'package:kart_project/design/custom_list_tile.dart';
import 'package:kart_project/design/loading_interface.dart';
import 'package:kart_project/providers/kelly_controller/controller_errors.dart';
import 'package:kart_project/providers/kelly_controller/kelly_controller.dart';
import 'package:kart_project/strings.dart';
import 'package:provider/provider.dart';

class DriveSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ControllerErrors(),
        RestartController(),
        PowerController(),
        ControllerData(),
      ],
    );
  }
}

class ControllerErrors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<KellyController, ControllerError?>(
      selector: (context, kellyController) => kellyController.error,
      builder: (BuildContext context, error, _) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 150),
          child: error == null
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8.0),
                      child: CustomListTile(
                        icon: Icon(
                          error.icon,
                          color: Theme.of(context).errorColor,
                        ),
                        title: error.title,
                        subtitle: error.message,
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class RestartController extends StatelessWidget {
  void restart(BuildContext context) {
    LoadingInterface.dialog(
      context,
      message: Strings.restartingMotorController,
    );
    context.read<KellyController>().restart().whenComplete(
          () => Navigator.pop(context),
        );
  }

  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: Strings.power,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomListTile(
          icon: Icon(EvaIcons.refreshOutline),
          title: Strings.reboot,
          subtitle: Strings.restartMotorController,
          onPressed: () {
            restart(context);
          },
        ),
      ),
    );
  }
}

class ControllerData extends StatelessWidget {
  Widget element(String topic, dynamic data) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Text("$topic: $data"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: Strings.monitor,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Consumer<KellyController>(
          builder: (context, controller, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                element('Speed', controller.speed),
                element('Battery', controller.batteryLevel),
                element('Motor Current', controller.motorCurrent),
                element('Voltage', controller.batteryVoltage),
                element('Throttle Signal', controller.throttleSignal),
                element('Controller Temp', controller.controllerTemperature),
                element('Motor Temp', controller.motorTemperature),
                element('Motor State Cmd', controller.motorStateCommand),
                element('Motor State Feedback', controller.motorStateFeedback),
              ],
            );
          },
        ),
      ),
    );
  }
}

// TODO: Remove after testing
class PowerController extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PowerControllerState();
  }
}

class _PowerControllerState extends State<PowerController> {
  late KellyController controller;

  @override
  Widget build(BuildContext context) {
    return Consumer<KellyController>(
      builder: (context, controller, child) {
        return CardWithTitle(
          title: "Power",
          child: Column(
            children: [
              Switch(
                value: controller.isOn,
                onChanged: controller.setPower,
              ),
              Text("Motor enabled:"),
              Switch(
                value: controller.motorEnabled,
                onChanged: controller.enableMotor,
              ),
            ],
          ),
        );
      },
    );
  }
}
