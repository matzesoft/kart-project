import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/interfaces/cmd_interface.dart';
import 'package:kart_project/pin.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/providers/cooling_provider.dart';
import 'package:kart_project/providers/motor_controller_provider.dart';
import 'package:kart_project/providers/light_provider.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/settings/settings.dart';
import 'package:provider/provider.dart';

/// Provides methods to unlock, lock or shutdown the kart.
class SystemProvider extends ChangeNotifier {
  final _cmdInterface = CmdInterface();
  bool _locked = true;
  DeveloperOptions? _devOptions;
  bool _devOptionsEnabled = false;

  /// If true the user has to input a pin code to unlock the kart.
  bool get locked => _locked;

  /// Must be enabled with [enableDevOptions]. Allow access to deeper system
  /// components.
  DeveloperOptions get devOptions {
    if (!devOptionsEnabled) throw StateError("DevOptions not enabled.");
    _devOptions ??= DeveloperOptions._(this);
    return _devOptions!;
  }

  /// If developer options are enabled.
  bool get devOptionsEnabled => _devOptionsEnabled;

  bool allowLock(MotorControllerProvider kellyController) {
    return (kellyController.speed <= 0);
  }

  /// Sets [locked] to true.
  void lock(MotorControllerProvider kellyController) {
    if (allowLock(kellyController)) {
      _locked = true;
      kellyController.enableMotor(false);
      notifyListeners();
    }
  }

  /// If [pin] correct [locked] will be set to false.
  void unlock(BuildContext context, String pin) {
    if (pin != Pin.pin) {
      context.showNotification(
        icon: EvaIcons.closeOutline,
        message: Strings.wrongPincode,
      );
    } else {
      _locked = false;
      notifyListeners();
    }
  }

  /// Checks the pin with the [devPin] and initalizes the [DeveloperOptions]
  /// if correct.
  void enableDevOptions(BuildContext context, String pin) {
    if (pin != Pin.devPin) {
      context.showNotification(
        icon: EvaIcons.closeOutline,
        message: Strings.wrongPincode,
      );
    } else {
      _devOptionsEnabled = true;
      context.showNotification(
        icon: EvaIcons.codeOutline,
        message: Strings.devOptionsEnabled,
      );
      notifyListeners();
    }
  }

  /// Sets [devOptionsEnabled] to false.
  void disableDevOptions(BuildContext context) {
    _devOptionsEnabled = false;
    context.showNotification(
      icon: EvaIcons.codeOutline,
      message: Strings.devOptionsDisabled,
    );
    notifyListeners();
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

class DeveloperOptions {
  SystemProvider _controller;

  DeveloperOptions._(this._controller);

  /// Enables the kart-service in systemd.
  void enableKartService() {
    _controller._cmdInterface.runCmd('sudo systemctl enable kart-project');
  }

  /// Disables the kart-service in systemd.
  void disableKartService() {
    _controller._cmdInterface.runCmd('sudo systemctl disable kart-project');
  }

  // Think about funtionality and need of the function
  // /// Calls [_powerOffProviders] and exits to the Linux command line.
  // void disableAppAndQuit(BuildContext context, String pin) {
  //   if (checkPin(context, pin)) {
  //     _cmdInterface.runCmd('pkill flutter-pi');
  //   }
  // }

  static const _NOTIFY_ID = "TEST_ERROR";

  void createTestError(BuildContext context) {
    final error = ErrorNotification(
      _NOTIFY_ID,
      icon: EvaIcons.alertCircleOutline,
      categorie: "Test",
      title: "Testfehlermeldung",
      message:
          "Diese Meldung dient zum Testen der Error Notifications Schnittstelle. "
          "Es sollte eine Nachricht hinterlegt sein, welche den Fehler genauer beschreibt.",
      moreDetails: (context) => Navigator.pushNamed(
        context,
        Settings.route,
        arguments: settings.length - 1, // Developer Options
      ),
    );
    context.read<NotificationsProvider>().error.create(error);
  }

  void closeTestError(BuildContext context) {
    context.read<NotificationsProvider>().error.close(_NOTIFY_ID);
  }

  void setFanOutput(BuildContext context, double value) {
    final fan = context.read<CoolingProvider>().fan;
    fan.output = value;
  }
}
