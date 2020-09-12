import 'package:flutter/material.dart';
import 'package:kart_project/design/sized_alert_dialog.dart';
import 'package:kart_project/strings.dart';

class LoadingInterface extends StatelessWidget {
  final String message;

  LoadingInterface({this.message});

  /// Shows a dialog with a [CircularProgressIndicator] and a message.
  LoadingInterface.dialog(BuildContext context, {this.message}) {
    showDialog(
      context: context,
      builder: (context) => dialogInterface(),
    );
  }

  /// Interface of the dialog.
  Widget dialogInterface() {
    return WillPopScope(
      onWillPop: () async => false,
      child: SizedAlertDialog(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LoadingInterface(message: message),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            message != null ? message : Strings.loading,
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
