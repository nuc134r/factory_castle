import 'package:factory_castle_flutter/factory_castle_flutter.dart';

import '../counter_service.dart';

class IncrementButtonModel extends ViewModelBase {
  IncrementButtonModel(this._service);

  Future<void> increment() async {
    setBusy();
    await _service.increment();
    setIdle(hasError: false);
  }

  final CounterService _service;
}
