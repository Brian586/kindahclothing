import 'dart:async';

import 'package:flutter/material.dart';

import '../config.dart';

class CountdownTimer extends StatefulWidget {
  final bool isStart;
  const CountdownTimer({super.key, required this.isStart});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  int _minutes = 5;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.isStart) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          if (_minutes > 0) {
            _minutes--;
            _seconds = 59;
          } else {
            _timer!.cancel();
          }
        }
      });
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _minutes = 0;
    _seconds = 0;
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isStart != widget.isStart) {
      if (widget.isStart) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$_minutes:${_seconds.toString().padLeft(2, '0')}',
          style: const TextStyle(color: Config.customBlue),
        ),
      ],
    );
  }
}
