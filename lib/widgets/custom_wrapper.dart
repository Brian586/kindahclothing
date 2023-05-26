import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class CustomWrapper extends StatelessWidget {
  final Widget? child;
  const CustomWrapper({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600.0, minWidth: 300.0),
      child: child,
    );
    // return ResponsiveWrapper(
    //   maxWidth: 600,
    //   minWidth: 300,
    //   defaultScale: true,
    //   breakpoints: const [
    //     ResponsiveBreakpoint.resize(480, name: MOBILE),
    //     ResponsiveBreakpoint.autoScale(800, name: TABLET),
    //     ResponsiveBreakpoint.resize(1000, name: DESKTOP),
    //     ResponsiveBreakpoint.autoScale(2460, name: '4K'),
    //   ],
    //   child: child,
    // );
  }
}
