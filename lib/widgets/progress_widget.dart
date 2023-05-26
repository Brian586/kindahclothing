import 'package:flutter/material.dart';
import 'package:kindah/config.dart';

circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(vertical: 200.0),
    child: const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Config.customBlue),
    ),
  );
}

linearProgress() {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 12.0),
    child: const LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Config.customBlue),
    ),
  );
}
