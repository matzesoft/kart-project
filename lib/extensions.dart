import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/providers/profil_provider/profil_provider.dart';
import 'package:provider/provider.dart';

extension ProviderExtensions<T> on BuildContext {
  /// Returns the instance of the [ProfilReader].
  ProfilProvider profil() => this.read<ProfilProvider>();

  /// Shows a error message using the [NotificationsProvider].
  void showErrorNotification(String message) {
    this.read<NotificationsProvider>().showErrorNotification(message);
  }

  void showInformNotification({IconData icon, String message}) {
    this.read<NotificationsProvider>().showInformNotification(
          icon: icon,
          message: message,
        );
  }

  /// Shows a confirm notification using the [NotificationsProvider].
  void showNotification({IconData icon, String message}) {
    this.read<NotificationsProvider>().showSimpleNotification(
          icon: icon,
          message: message,
        );
  }
}
