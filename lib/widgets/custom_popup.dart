import 'package:flutter/material.dart';

import '../config.dart';
import 'custom_button.dart';

class CustomPopup extends StatefulWidget {
  final String? title;
  final Widget? body;
  final void Function()? onCancel;
  final void Function()? onAccepted;
  final String? acceptTitle;
  const CustomPopup(
      {super.key,
      this.title,
      this.onAccepted,
      this.onCancel,
      this.body,
      this.acceptTitle});

  @override
  State<CustomPopup> createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title!,
        style: const TextStyle(
            color: Config.customGrey, fontWeight: FontWeight.w800),
      ),
      content: widget.body,
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text(
            "CANCEL",
            style: TextStyle(color: Config.customBlue),
          ),
        ),
        CustomButton(
          onPressed: widget.onAccepted,
          title: widget.acceptTitle,
          iconData: Icons.done_rounded,
          height: 30.0,
        )
      ],
    );
  }
}

class OptionsPopup extends StatelessWidget {
  final String? title;
  final Widget? body;
  const OptionsPopup({super.key, this.title, this.body});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title!,
        style: const TextStyle(
            color: Config.customGrey, fontWeight: FontWeight.w800),
      ),
      content: body,
    );
  }
}

class ErrorPopup extends StatelessWidget {
  final String? title;
  final Widget? body;
  const ErrorPopup({super.key, this.title, this.body});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title!,
        style: const TextStyle(
            color: Config.customGrey, fontWeight: FontWeight.w800),
      ),
      content: body,
      actions: [
        CustomButton(
          onPressed: () => Navigator.pop(context),
          title: "Close",
          iconData: Icons.error,
          height: 30.0,
        )
      ],
    );
  }
}
