import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';

/// Custom ListTile with better adapts to the rest of the design.
class CustomListTile extends StatelessWidget {
  final Function onPressed;
  final Function onDoubleTap;
  final Widget icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final EdgeInsets padding;

  CustomListTile({
    this.onPressed,
    this.onDoubleTap,
    this.icon,
    this.title: "",
    this.subtitle: "",
    this.trailing,
    this.padding: const EdgeInsets.all(2.0),
  });

  @override
  Widget build(BuildContext context) {
    /// Only adds an InkWell to widget tree if a onPressed function is given.
    return InkWell(
      onTap: onPressed,
      onDoubleTap: onDoubleTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Visibility(
              visible: icon != null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: icon,
              ),
            ),
            // Makes sure text overflows correctly.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: trailing != null,
              child: trailing ?? SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
