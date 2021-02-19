import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.only(
            bottom: 8.0,
            left: 16.0,
            top: 36.0,
            right: 16.0,
          ),
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
