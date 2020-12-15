import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationsProvider extends ChangeNotifier {
  final _duration = Duration(milliseconds: 2500);

  /// Should confirm the user quickly if the requested process was sucessfull.
  /// For example when deleting a profil or changing a setting.
  void showConfirmNotification({IconData icon, String message}) {
    showOverlayNotification(
      (context) {
        return _ConfirmNotification(
          icon: icon,
          message: message,
        );
      },
      duration: _duration,
      position: NotificationPosition.bottom,
    );
  }

  /// Should the user quickly inform about the failure of the requested
  /// process. Only takes a [message]. The icon is always set to a alert icon.
  void showErrorNotification({String message}) {
    showOverlayNotification(
      (context) {
        return _ConfirmNotification(
          icon: EvaIcons.alertCircleOutline,
          message: message,
        );
      },
      duration: _duration,
      position: NotificationPosition.bottom,
    );
  }
}

/// Overlay normally presented at the bottom of the screen. Takes a [icon] and
/// the [message] as the confirmation message.
class _ConfirmNotification extends StatelessWidget {
  final double _widthFactor = 0.5;
  final IconData icon;
  final String message;

  _ConfirmNotification({this.icon: EvaIcons.infoOutline, this.message: ""});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(icon),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(message),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
