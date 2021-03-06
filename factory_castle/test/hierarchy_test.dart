import 'package:factory_castle/factory_castle.dart';
import 'package:test/test.dart';

void main() {
  group('hierarchy', () {
    test('resolves component from parent container', () {
      final parentContainer = FactoryContainer();
      final childContainer = FactoryContainer();
      parentContainer.attachChildContainer(childContainer);
      parentContainer.register((c) => 123);

      final result = childContainer.resolve<int>();

      expect(result, 123);
    });

    test('resolves component from current container', () {
      final parentContainer = FactoryContainer();
      final childContainer = FactoryContainer();
      parentContainer.attachChildContainer(childContainer);
      parentContainer.register((c) => 123);
      childContainer.register((c) => 321);

      final result = childContainer.resolve<int>();

      expect(result, 321);
    });

    test('resolves named component from parent container', () {
      final parentContainer = FactoryContainer();
      final childContainer = FactoryContainer();
      parentContainer.attachChildContainer(childContainer);
      parentContainer.register((c) => 123, name: 'test');
      childContainer.register((c) => 321);

      final result = childContainer.resolve<int>(name: 'test');

      expect(result, 123);
    });

    test('Cannot attach same container as child', () {
      expect(() {
        final container = FactoryContainer();
        container.attachChildContainer(container);
      }, throwsUnsupportedError);
    });
  });
}
