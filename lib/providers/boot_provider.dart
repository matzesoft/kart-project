import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/interfaces/cmd_interface.dart';
import 'package:kart_project/pin.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/providers/light_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:provider/provider.dart';

/// Provides methods to unlock, lock or shutdown the kart.
class BootProvider extends ChangeNotifier {
  final _cmdInterface = CmdInterface();
  bool _locked = true;

  /// If true the user has to input a pin code to unlock the kart.
  bool get locked => _locked;

  /// Sets [locked] to true.
  void lock() {
    _locked = true;
    notifyListeners();
  }

  /// If [pin] correct [locked] will be set to false.
  void unlock(BuildContext context, String pin) {
    if (checkPin(context, pin)) {
      _locked = false;
      context.showNotification(
        icon: EvaIcons.unlockOutline,
        message: Strings.unlocked,
      );
      notifyListeners();
    }
  }

  /// Calls [_powerOffProviders] and exits to the Linux command line.
  void exitToCmd(BuildContext context, String pin) {
    if (checkPin(context, pin)) {
      throw UnimplementedError();
      // TODO: Implement
      _powerOffProviders(context);
    }
  }

  /// Returns true if the [pin] is correct. Shows a notification if not.
  bool checkPin(BuildContext context, String pin) {
    if (pin != Pin.pin) {
      context.showNotification(
        icon: EvaIcons.closeOutline,
        message: Strings.wrongPincode,
      );
      return false;
    }
    return true;
  }

  /// Shuts down the RaspberryPi.
  Future powerOff(BuildContext context) async {
    _powerOffProviders(context);
    _cmdInterface.runCmd('sudo poweroff');
  }

  /// Reboots the RaspberryPi
  Future reboot(BuildContext context) async {
    _powerOffProviders(context);
    _cmdInterface.runCmd('sudo reboot'); // Test
  }

  /// Calls all providers to update their values for power off.
  Future _powerOffProviders(BuildContext context) async {
    context.read<LightProvider>().powerOff();
  }
}
