import 'package:factory_castle_flutter/factory_castle_flutter.dart';

import '../counter_service.dart';

class HomePageModel extends ViewModelBase {
  HomePageModel(this._service) {
    _service.changed.listen((event) => onCounterChanged());
  }

  int get value => _value;

  Future incrementCounter() => _service.increment();

  @override
  Future<void> onInit() async {
    setBusy();
    await Future.delayed(Duration(seconds: 2));
    _value = _service.value;
    setIdle(hasError: false);
  }

  void onCounterChanged() {
    _value = _service.value;
    notifyListeners();
  }

  final CounterService _service;
  int _value;
}
