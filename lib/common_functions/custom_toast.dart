import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showCustomToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    webShowClose: true,
    timeInSecForIosWeb: 30,
    textColor: Colors.white,
    webBgColor: "linear-gradient(to right, #000000, #000000)",
  );
}
