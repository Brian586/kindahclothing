// import 'dart:async';
// import 'package:shared_preferences/shared_preferences.dart';

// class SharedPreferencesStream {
//   final String? _key;
//   final StreamController<String>? _controller;
//   SharedPreferences? _prefs;

//   SharedPreferencesStream(this._key)
//       : _controller = StreamController<String>.broadcast() {
//     SharedPreferences.getInstance().then((prefs) {
//       _prefs = prefs;
//       _prefs!.getString(_key!)?.let((value) => _controller!.add(value));
//       _prefs!.onChanged.listen(_onPrefsChanged);
//     });
//   }

//   Stream<String> get stream => _controller!.stream;

//   void _onPrefsChanged(String key) {
//     if (key == _key) {
//       _prefs!.getString(_key!)?.let((value) => _controller?.add(value));
//     }
//   }

//   void dispose() {
//     _controller?.close();
//   }
// }
