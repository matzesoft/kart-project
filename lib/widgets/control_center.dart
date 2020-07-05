import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';

class ControlCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("Control Center");
  }
}

class ControlCenterButton extends StatelessWidget {
  final IconData icon;
  final bool selected;

  ControlCenterButton({@required this.icon, this.selected});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: AppTheme.customElevation,
      borderRadius: BorderRadius.circular(AppTheme.customBorderRadius),
      shadowColor: AppTheme.customShadowColor(context),
      color: selected
          ? Theme.of(context).accentColor
          : Theme.of(context).canvasColor,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(
          icon,
          color: selected ?
            ,
          
        ),
      ),
    );
  }
}
