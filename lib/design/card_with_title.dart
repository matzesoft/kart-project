import 'package:flutter/material.dart';

class CardWithTitle extends StatelessWidget {
  final String title;
  final EdgeInsets margin;
  final Widget? child;

  CardWithTitle({
    this.title: "",
    this.margin: const EdgeInsets.all(8.0),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          Card(
            child: child,
          ),
        ],
      ),
    );
  }
}
