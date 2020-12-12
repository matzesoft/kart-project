import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/providers/profil_provider/profil_provider.dart';
import 'package:provider/provider.dart';

extension ProviderExtensions<T> on BuildContext {
  /// Makes the widget listen to changes on `T`.
  T watch<T>() => Provider.of<T>(this);

  /// Returns `T` without listening to it.
  T read<T>() => Provider.of<T>(this, listen: false);

  /// Returns the instance of the [ProfilReader].
  ProfilProvider profil() => this.read<ProfilProvider>();

  /// Shows a error message using the [NotificationsProvider].
  void showErrorNotification(String message) {
    this.read<NotificationsProvider>().showErrorNotification(
          message: message,
        );
  }

  /// Shows a confirm notification using the [NotificationsProvider].
  void showConfirmNotification({IconData icon, String message}) {
    this.read<NotificationsProvider>().showConfirmNotification(
          icon: icon,
          message: message,
        );
  }
}
