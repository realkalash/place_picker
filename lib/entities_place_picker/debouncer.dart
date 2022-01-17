import 'dart:async';

import 'package:flutter/material.dart';

class Debouncer {
  int milliseconds;
  // VoidCallback? action;
  Timer _timer;

  Debouncer({this.milliseconds = 500});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds ?? 500), action);
  }

  void stop() {
    _timer?.cancel();
  }
}
