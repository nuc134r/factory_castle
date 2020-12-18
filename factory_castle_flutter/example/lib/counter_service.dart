import 'dart:async';

class CounterService {
  int get value => _counter;
  Stream get changed => _changedController.stream;

  Future increment() async {
    await Future.delayed(Duration(seconds: 1));
    _counter++;
    _changedController.add(null);
  }

  StreamController _changedController = StreamController.broadcast();
  int _counter = 0;
}
