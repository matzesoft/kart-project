import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/providers/profil_provider.dart';
import 'package:kart_project/providers/system_provider.dart';
import 'package:provider/provider.dart';

extension ProviderExtensions<T> on BuildContext {
  /// Returns the current profil.
  Profil profil() => this.read<ProfilProvider>().currentProfil;

  /// Returns true if the kart is locked.
  bool locked() => this.read<SystemProvider>().locked;

  /// Shows a error message using the [NotificationsProvider].
  void showExceptionNotification(String message) {
    this.read<NotificationsProvider>().simple.showException(message);
  }

  void showInformNotification({IconData icon, String message}) {
    this.read<NotificationsProvider>().simple.showInform(
          icon: icon,
          message: message,
        );
  }

  /// Shows a confirm notification using the [NotificationsProvider].
  void showNotification({IconData icon, String message}) {
    this.read<NotificationsProvider>().simple.show(
          icon: icon,
          message: message,
        );
  }
}

extension FlutterGpiodExtensions on GpioLine {
  void toggle() {
    final value = this.getValue();
    this.setValue(!value);
  }
}
