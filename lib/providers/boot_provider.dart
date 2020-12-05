import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/interfaces/cmd_interface.dart';
import 'package:kart_project/pin.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/strings.dart';

/// Provides methods to unlock, lock or shutdown the kart.
class BootProvider extends ChangeNotifier {
  final CmdInterface _cmdInterface = CmdInterface();

  /// If true the user has to input a pin code to unlock the kart.
  bool locked = true;

  /// Checks if the given [pin] is correct. If correct [locked] will be set to
  /// false and true is returned.
  bool unlock(BuildContext context, String pin) {
    final notifications = context.read<NotificationsProvider>();
    if (pin != Pin.pin) {
      notifications.showConfirmNotification(
        icon: EvaIcons.closeOutline,
        message: Strings.wrongPincode,
      );
      return false;
    }

    locked = false;
    notifications.showConfirmNotification(
      icon: EvaIcons.unlockOutline,
      message: Strings.unlocked,
    );
    notifyListeners();
    return true;
  }

  void lock() {
    // TODO: Implement
    locked = true;
    notifyListeners();
  }

  void powerOff() {
    // TODO: Implement Providers
    _cmdInterface.runCmd('sudo poweroff');
  }
}
