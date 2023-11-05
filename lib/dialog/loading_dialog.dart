import 'package:flutter/material.dart';
import 'package:kindah/widgets/progress_widget.dart';

class LoadingDialog extends StatelessWidget {
  final String? message;
  const LoadingDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: SizedBox(
        height: 70.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            circularProgress(),
            const SizedBox(width: 10),
            Text(message!),
          ],
        ),
      ),
    );
  }
}

void showLoadingDialog(BuildContext context, String message) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return LoadingDialog(
          message: message,
        );
      });
}
