import 'package:flutter/material.dart';

class CustomTag extends StatelessWidget {
  final String? title;
  final Color? color;
  const CustomTag({super.key, this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: color!.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Text(
          title!,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
