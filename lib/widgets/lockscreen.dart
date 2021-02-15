import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/loading_interface.dart';
import 'package:kart_project/design/number_pad.dart';
import 'package:kart_project/design/sized_alert_dialog.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/boot_provider.dart';
import 'package:provider/provider.dart';
import 'package:kart_project/strings.dart';

class Lockscreen extends StatelessWidget {
  /// Calls the unlock method in the [BootProvider] with the pin of the [NumberPad]
  void unlock(BuildContext context, String pin) {
    context.read<BootProvider>().unlock(context, pin);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WelcomeMessage(),
        ),
        Expanded(
          child: NumberPad(
            onConfirm: (String pin) {
              unlock(context, pin);
            },
          ),
        ),
      ],
    );
  }
}

class WelcomeMessage extends StatelessWidget {
  void _showPowerOffDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => BootOptionsDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
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
        Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
            icon: Icon(EvaIcons.powerOutline),
            iconSize: AppTheme.iconButtonSize,
            onPressed: () {
              _showPowerOffDialog(context);
            },
          ),
        ),
      ],
    );
  }
}

class BootOptionsDialog extends StatefulWidget {
  @override
  _BootOptionsDialogState createState() => _BootOptionsDialogState();
}

class _BootOptionsDialogState extends State<BootOptionsDialog> {
  /// Set to true when work is in progress. Normaly used to check wether to show
  /// a [LoadingInterface] or not.
  bool _processing = false;

  Future powerOff(BuildContext context) async {
    setState(() {
      _processing = true;
    });
    await context.read<BootProvider>().powerOff(context);
  }

  Future reboot(BuildContext context) async {
    setState(() {
      _processing = true;
    });
    await context.read<BootProvider>().reboot(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_processing) {
      return LoadingInterface(
        message: Strings.poweringOff,
      ).dialogInterface();
    }
    return SizedAlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(height: 8.0), // Needed to set elements in full center
          _BootOption(
            title: Strings.powerOff,
            icon: EvaIcons.powerOutline,
            onTap: () {
              powerOff(context);
            },
          ),
          _BootOption(
            title: Strings.reboot,
            icon: EvaIcons.refreshOutline,
            onTap: () {
              reboot(context);
            },
          ),
        ],
      ),
    );
  }
}

class _BootOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onTap;

  _BootOption({this.title, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(icon),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(title),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
