import 'package:flutter/material.dart';
import 'package:kart_project/design/custom_list_tile.dart';
import 'package:kart_project/providers/kelly_controller/controller_errors.dart';
import 'package:kart_project/providers/kelly_controller/kelly_controller.dart';
import 'package:provider/provider.dart';

class DriveSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ControllerState(),
      ],
    );
  }
}

class ControllerState extends StatelessWidget {
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
