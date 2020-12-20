import 'dart:async';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationsProvider extends ChangeNotifier {
  /// Defines if currently a notification is shown on screen.
  bool _notificationOnScreen = false;

  /// Used to count down if the notifiation is still shown.
  Timer _timer;

  /// Entry to dismiss the shown notification.
  OverlaySupportEntry _entry;

  /// Should confirm the user quickly if the requested process was sucessfull.
  /// For example when deleting a profil or changing a setting.
  void showSimpleNotification({IconData icon, String message}) {
    _showNotification(icon: icon, message: message);
  }

  /// Shows a notification for 8 seconds and allows the message be longer than
  /// one line.
  void showInformNotification({
    IconData icon,
    String message,
  }) {
    _showNotification(
      icon: icon,
      message: message,
      duration: Duration(seconds: 10),
      maxLines: 3,
    );
  }

  /// Should the user quickly inform about the failure of the requested
  /// process. Uses the [OvlerayNotification] ui. Only takes a [message].
  /// The icon is always set to a alert icon.
  void showErrorNotification(String message) {
    _showNotification(
      icon: EvaIcons.alertCircleOutline,
      message: message,
    );
  }

  /// Shows a [_OvlerayNotification] at the bottom of the screen. If there is
  /// already a notification shown it will be dismissed.
  void _showNotification({
    IconData icon,
    String message,
    Duration duration: const Duration(milliseconds: 2500),
    int maxLines,
  }) {
    _mayDismissNotification();
    _notificationInit(duration);

    _entry = showOverlayNotification(
      (context) {
        return OvlerayNotification(
          icon: icon,
          message: message,
          onDismissed: () {
            _mayDismissNotification(animate: false);
          },
          maxLines: maxLines,
        );
      },
      duration: duration,
      position: NotificationPosition.bottom,
    );
  }

  /// Sets [_notificationOnScreen] to true and starts the [_timer].
  void _notificationInit(Duration duration) {
    _notificationOnScreen = true;
    _timer = Timer(duration, () {
      _notificationOnScreen = false;
    });
  }

  /// If [_notificationOnScreen] is true the notification will be dismissed and
  /// the [_timer] cancled.
  void _mayDismissNotification({bool animate: true}) {
    if (_notificationOnScreen) {
      _entry.dismiss(animate: animate);
      if (_timer != null && _timer.isActive) _timer.cancel();
    }
  }
}

/// Overlay normally presented at the bottom of the screen. Takes a [icon] and
/// the [message] as the confirmation message.
class OvlerayNotification extends StatelessWidget {
  final double _widthFactor = 0.5;
  final IconData icon;
  final String message;
  final Function onDismissed;
  final int maxLines;

  OvlerayNotification({
    this.icon: EvaIcons.infoOutline,
    this.message: "",
    this.onDismissed,
    this.maxLines: 1,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key("key"),
      direction: DismissDirection.down,
      onDismissed: (_) {
        onDismissed();
      },
      child: FractionallySizedBox(
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
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        message,
                        maxLines: maxLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
