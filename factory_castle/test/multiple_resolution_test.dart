import 'package:factory_castle/factory_castle.dart';
import 'package:test/test.dart';

void main() {
  group('multiple resolution', () {
    test('can resolve multiple components', () {
      final container = FactoryContainer();

      container.register((c) => 123);
      container.register((c) => 321);

      expect(container.resolveAll<int>(), <int>[123, 321]);
    });

    test('can resolve multiple components from parent container', () {
      final parentContainer = FactoryContainer();
      final container = FactoryContainer();
      parentContainer.attachChildContainer(container);

      parentContainer.register((c) => 123);
      parentContainer.register((c) => 321);

      expect(container.resolveAll<int>(), <int>[123, 321]);
    });
  });
}
