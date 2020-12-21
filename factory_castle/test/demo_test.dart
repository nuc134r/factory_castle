import 'package:factory_castle/factory_castle.dart';
import 'package:test/test.dart';

abstract class ILogger {
  void log(String m);
}

class Logger implements ILogger {
  final String name;
  Logger(this.name);

  void log(String m) {/* ... */}
}

class DataRepository {
  final ILogger logger;
  DataRepository(this.logger);
}

class ListViewModel {
  final ILogger logger;
  final DataRepository repo;

  ListViewModel(this.logger, this.repo);

  void update() {}
}

void main() {
  test('demo', () {
    final container = FactoryContainer();

    container.register<ILogger>((c) => Logger('Demo'));
    container.register((c) => DataRepository(c.res()));
    container.register((c) => ListViewModel(c.res(), c.res()));

    final viewModel = container.resolve<ListViewModel>();

    viewModel.update();
  });
}
