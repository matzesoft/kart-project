import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/extensions.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationsProvider extends ChangeNotifier {
  late final simple = SimpleNotificationsController();
  late final error = ErrorNotificationController(this);

  void notify() {
    notifyListeners();
  }
}

/// Used to control simple notifications shown at the bottom. Simple notifications
/// are removed after shown and used to confirm the user a request and inform
/// him about a exception.
class SimpleNotificationsController {
  Notification? _notification;

  /// Should confirm the user quickly if the requested process was sucessfull.
  /// For example when deleting a user or changing a setting.
  void show({required IconData icon, required String message}) {
    _showNotification(icon: icon, message: message);
  }

  /// Shows a notification for 8 seconds and allows the message be longer than
  /// one line.
  void showInform({required IconData icon, required String message}) {
    _showNotification(
      icon: icon,
      message: message,
      duration: Duration(seconds: 10),
      maxLines: 3,
    );
  }

  /// Should the user quickly inform about the failure of the requested
  /// process. Uses the [SimpleNotification] ui. Only takes a [message].
  /// The icon is always set to a alert icon.
  void showException(String message) {
    _showNotification(
      icon: EvaIcons.alertCircleOutline,
      message: message,
    );
  }

  /// Shows a [_OvlerayNotification] at the bottom of the screen. If there is
  /// already a notification shown it will be dismissed.
  void _showNotification({
    required IconData icon,
    required String message,
    Duration duration: const Duration(milliseconds: 2500),
    int maxLines: 2,
  }) async {
    if (_notification != null && _notification!.shown) {
      _notification!.tryDimiss();
    }

    logToConsole("SimpleNotificationsController", "_showNotification",
        "message: $message");
    _notification = SimpleNotification(
        icon: icon, message: message, duration: duration, maxLines: maxLines);
    _notification!.show();
  }
}

/// Error notifications should be used for critical failures. For example overheat
/// of the motor. As long as they persist, they are shown in the ControlCenter.
class ErrorNotificationController {
  NotificationsProvider _provider;
  List<ErrorNotification> errors = [];

  ErrorNotificationController(this._provider);

  /// Adds the error to the list of [errors]. If there already is a error
  /// registerd with the same id, the request will be ignored.
  void create(ErrorNotification notification) {
    logToConsole("ErrorNotificationController", "create",
        "Try create new error: ${notification.id}");
    if (!errors.any((n) => n.id == notification.id)) {
      errors.add(notification);
      notification.show();
    }
    _provider.notify();
  }

  /// Dismisses the notification if still shown and removes the error from [errors].
  void tryClose(String id) {
    logToConsole(
        "ErrorNotificationController", "close", "Try close error: $id");
    final notification = errors.where((n) => n.id == id).toList();
    notification.forEach((notification) {
      notification.tryDimiss();
      errors.remove(notification);
    });
    _provider.notify();
  }
}

/// Provides functions to show and dismiss the notification.
abstract class Notification {
  final _widthFactor = 0.5;

  /// Position of the notification.
  final NotificationPosition position;

  /// The direction the user swipes the notification away.
  final DismissDirection dismissDirection;

  /// Show long the notification will be presented.
  final Duration duration;

  /// Key required by the [Dismissable].
  final String widgetKey;

  /// Moves the widget upper to the top. Needed to ignore SafeArea widget.
  final bool translate;

  /// Entry to dismiss the notification.
  OverlaySupportEntry? _entry;
  bool _shown = false;

  Notification({
    this.position: NotificationPosition.bottom,
    this.dismissDirection: DismissDirection.down,
    this.duration: const Duration(milliseconds: 5000),
    this.widgetKey: "notify_key",
    this.translate: false,
  });

  /// If the notification is shown on screen.
  bool get shown => _shown;

  /// Shows the notification as an overlay.
  void show() {
    _shown = true;
    _entry = showOverlayNotification(
      (context) => this._widget(context),
      duration: duration,
      position: position,
    );
    _entry!.dismissed.whenComplete(() => _shown = false);
  }

  /// Dismisses the notification if [shown].
  void tryDimiss({bool animate: true}) {
    if (shown) _entry!.dismiss(animate: animate);
  }

  /// Content of the notification.
  Widget _content(BuildContext context);

  /// UI of the notification.
  Widget _widget(BuildContext context) {
    return Transform.translate(
      offset: translate ? Offset(0, -25) : Offset.zero,
      child: Dismissible(
        key: Key(widgetKey),
        direction: dismissDirection,
        onDismissed: (_) {
          tryDimiss(animate: false);
        },
        child: FractionallySizedBox(
          widthFactor: _widthFactor,
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 8.0,
              left: 16.0,
              top: 36.0,
              right: 16.0,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _content(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay normally presented at the bottom of the screen. Takes a [icon] and
/// the [message] as the confirmation message.
class SimpleNotification extends Notification {
  final IconData icon;
  final String message;
  final int maxLines;

  SimpleNotification({
    this.icon: EvaIcons.infoOutline,
    this.message: "",
    Duration duration: const Duration(milliseconds: 2500),
    this.maxLines: 1,
  }) : super(duration: duration, widgetKey: "simple_notify");

  @override
  Widget _content(BuildContext context) {
    return Row(
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
    );
  }
}

class ErrorNotification extends Notification {
  final String id;
  final IconData icon;
  final String categorie;
  final String title;
  final String message;
  final Function(BuildContext context)? moreDetails;

  ErrorNotification(
    this.id, {
    this.icon: EvaIcons.alertTriangleOutline,
    this.categorie: "",
    this.title: "",
    this.message: "",
    this.moreDetails,
  }) : super(
          position: NotificationPosition.top,
          dismissDirection: DismissDirection.up,
          duration: Duration.zero,
          widgetKey: id,
          translate: true,
        );

  @override
  Widget _content(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Icon(icon, color: Theme.of(context).errorColor),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Theme.of(context).errorColor,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(message),
        ),
      ],
    );
  }
}
