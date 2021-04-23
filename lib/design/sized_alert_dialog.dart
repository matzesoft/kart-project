import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';

/// [AlertDialog] which does not allows its children to be bigger than the
/// [AppTheme.dialogSize].
class SizedAlertDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  SizedAlertDialog({
    this.title,
    this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: AppTheme.dialogSize,
      widthFactor: AppTheme.dialogSize,
      child: AlertDialog(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }
}
