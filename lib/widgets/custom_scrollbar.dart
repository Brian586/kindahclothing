import 'package:flutter/material.dart';
import 'package:kindah/config.dart';

class CustomScrollBar extends StatelessWidget {
  final Widget? child;
  final ScrollController? controller;
  const CustomScrollBar({super.key, this.child, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: controller,
      thumbVisibility: true,
      trackVisibility: true,
      radius: const Radius.circular(0.0),
      thumbColor: Config.customGrey.withOpacity(0.5),
      trackColor: Config.customGrey.withOpacity(0.1),
      thickness: 12.0,
      child: child!,
    );
  }
}
