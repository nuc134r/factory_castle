import 'dart:ui';

import 'package:factory_castle_flutter/factory_castle_flutter.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import '../counter_service.dart';

class IncrementButtonModel extends ViewModelBase with INeedTickerProvider {
  IncrementButtonModel(this._service);

  @override
  void onInit() {
    _controller = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 700),
    );

    colorAnimation = ColorTween(
      begin: Colors.red,
      end: Colors.deepPurple,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ))
      ..addListener(() => notifyListeners());

    _controller.forward();
  }

  Future<void> increment() async {
    setBusy();
    await _service.increment();
    setIdle(hasError: false);
  }

  AnimationController _controller;
  Animation<Color> colorAnimation;

  final CounterService _service;
}
