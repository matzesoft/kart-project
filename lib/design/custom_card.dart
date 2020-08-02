import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';


class CustomCard extends StatelessWidget {
  /// The content of the card.
  final Widget child;

  /// The title displayed above the card.
  final String title;

  /// Inner padding to the [child].
  final EdgeInsets padding;

  /// Outer padding of the card.
  final EdgeInsets margin;

  CustomCard({
    this.child,
    this.title,
    this.padding: const EdgeInsets.all(8.0),
    this.margin: const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        children: <Widget>[
          Visibility(
            visible: title == null ? false : true,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title == null ? "" : title.toUpperCase(),
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          ),
          Material(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.customBorderRadius),
            elevation: AppTheme.customElevation,
            shadowColor: AppTheme.customShadowColor(context),
            child: Padding(
              padding: padding,
              child: child,
            ),
          )
        ],
      ),
    );
  }
}
