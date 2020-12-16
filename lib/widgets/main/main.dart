import 'package:flutter/material.dart';
import 'package:kart_project/widgets/main/dashboard.dart';
import 'package:kart_project/widgets/main/entertainment.dart';

/// Main part of the app. Gives you information about your speed, lets you
/// control the light, etc.
class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Dashboard(),
        ),
        Expanded(
          flex: 7,
          child: Entertainment(),
        ),
      ],
    );
  }
}
