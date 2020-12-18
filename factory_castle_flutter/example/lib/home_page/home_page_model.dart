import 'dart:async';

import 'package:factory_castle_flutter/factory_castle_flutter.dart';
import 'package:flutter/cupertino.dart';

import '../counter_service.dart';

/// View models must extend [ChangeNotifier]. There is a handy [ViewModelBase] to make your life even easier.
class HomePageModel extends ViewModelBase {
  HomePageModel(this._service) {
    _subscription = _service.changed.listen((event) => onCounterChanged());
  }

  /// These public properties and methods are called from the view.
  int get value => _value;
  Future incrementCounter() async => await _service.increment();

  /// This is the place to initialize widget with data.
  /// Use [setBusy] and [setIdle] to set [ViewModelBase.isBusy] and [ViewModelBase.hasError] flags.
  @override
  Future<void> onInit() async {
    setBusy();
    await Future.delayed(Duration(seconds: 2));
    _value = _service.value;
    setIdle(hasError: false);
  }

  /// This is the place to unsubscribe from streams and free resources.
  @override
  Future<void> onDispose() async {
    await _subscription.cancel();
  }

  /// Call [notifyListeners] in order to rebuild your widget.
  /// [setBusy] and [setIdle] will also rebuild your widget.
  void onCounterChanged() {
    _value = _service.value;
    notifyListeners();
  }

  StreamSubscription _subscription;
  int _value;

  final CounterService _service;
}
