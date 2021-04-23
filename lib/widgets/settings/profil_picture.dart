import 'package:flutter/material.dart';

/// Shows a round background with the first letter of the name in it. If
/// [active] is set to true, the profil pircture will be highlighted.
/// 
/// Use [size] to change the height and width and text size of the widget.
class ProfilPicture extends StatelessWidget {
  final bool active;
  final String name;
  final double size;
  final EdgeInsets padding;
  final EdgeInsets margin;

  ProfilPicture({
    this.active: false,
    this.name: "",
    this.size: 48,
    this.padding: const EdgeInsets.all(6.0),
    this.margin: const EdgeInsets.all(12.0),
  });

  /// Color used by the title and the icon of the setting.
  Color? _textColor(BuildContext context) => active
      ? Theme.of(context).accentColor
      : Theme.of(context).textTheme.subtitle1!.color;

  /// Color used by the background of the profile picture.
  Color _backgroundColor(BuildContext context) => active
      ? Theme.of(context).accentColor.withOpacity(0.4)
      : Theme.of(context).canvasColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _backgroundColor(context),
      ),
      margin: margin,
      padding: padding,
      child: Text(
        name[0],
        style: Theme.of(context).textTheme.subtitle1!.copyWith(
              fontSize: size / 2,
              color: _textColor(context),
            ),
      ),
    );
  }
}
