import 'package:flutter/material.dart';
import 'package:kart_project/design/custom_card.dart';
import 'package:kart_project/strings.dart';

class LoadingInterface extends StatelessWidget {
  final String message;

  LoadingInterface({this.message});

  /// Shows a dialog with a [CircularProgressIndicator] and a message.
  LoadingInterface.dialog(BuildContext context, {this.message}) {
    // TODO: Set dialog to center
    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.6,
            heightFactor: 0.6,
            alignment: Alignment.center,
            child: Container(
              color: Colors.green, // TODO: Remove after testing
              child: Center(
                child: CustomCard(
                  padding: EdgeInsets.all(16.0),
                  child: LoadingInterface(message: message),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
