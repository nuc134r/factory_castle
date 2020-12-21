import 'package:factory_castle/exceptions.dart';
import 'package:factory_castle/factory_castle.dart';
import 'package:test/test.dart';

void main() {
  group('resolution', () {
    test('can resolve unnamed component by type', () {
      final container = FactoryContainer();

      container.register((c) => 123);

      expect(container.resolve<int>(), 123);
    });

    test('resolves last registered component', () {
      final container = FactoryContainer();

      container.register((c) => 123);
      container.register((c) => 321);

      expect(container.resolve<int>(), 321);
    });

    test('resolves correct component by name', () {
      final container = FactoryContainer();

      container.register((c) => 123);
      container.register((c) => 321, name: 'test1');

      expect(container.resolve<int>(name: 'test1'), 321);
    });

    test('resolves named component if name was not supplied', () {
      final container = FactoryContainer();

      container.register((c) => 123, name: 'test1');
      container.register((c) => 321, name: 'test2');

      expect(container.resolve<int>(), 321);
    });

    test('resolves by type that was used for registration', () {
      final container = FactoryContainer();

      container.register<Object>((c) => 321);

      expect(container.resolve<Object>(), 321);
    });

    test('resolves by type that was used for registration (named)', () {
      final container = FactoryContainer();

      container.register<Object>((c) => 123, name: 'test1');
      container.register<Object>((c) => 321, name: 'test2');

      expect(container.resolve<Object>(), 321);
    });

    test('resolves components that need other components', () {
      final container = FactoryContainer();

      container.register<int>((c) => 123);
      container.register<String>((c) => "test${c.res<int>()}");

      expect(container.resolve<String>(), 'test123');
    });

    test('resolves generic types', () {
      final container = FactoryContainer();

      container.register<List<int>>((c) => <int>[1, 2, 3]);

      expect(container.resolve<List<int>>(), <int>[1, 2, 3]);
    });

    test('resolves single instance for singleton', () {
      final container = FactoryContainer();

      container.register<List<int>>((c) => <int>[1, 2, 3]);

      final inst1 = container.resolve<List<int>>();
      final inst2 = container.resolve<List<int>>();
      final inst3 = container.resolve<List<int>>();

      expect(identical(inst1, inst2), true);
      expect(identical(inst2, inst3), true);
    });

    test('resolves different instances for transient', () {
      final container = FactoryContainer();

      container.register<List<int>>((c) => <int>[1, 2, 3], lifestyle: Lifestyle.Transient);

      final inst1 = container.resolve<List<int>>();
      final inst2 = container.resolve<List<int>>();
      final inst3 = container.resolve<List<int>>();

      expect(identical(inst1, inst2) && identical(inst2, inst3), false);
    });

    test('Unexisiting handler message contains type name', () {
      final container = FactoryContainer();
      String exceptionText;

      container.register<int>((c) => 123);
      try {
        container.resolve<String>();
      } catch (e) {
        exceptionText = e.toString();
        expect(e is HandlerNotFoundException, true);
      }

      expect(exceptionText, contains('String'));
    });

    test('Unexisiting component message contains type name and requested component name', () {
      final container = FactoryContainer();
      String exceptionText;

      container.register<int>((c) => 123);
      try {
        container.resolve<int>(name: 'test1');
      } catch (e) {
        exceptionText = e.toString();
        expect(e is ComponentNotFoundException, true);
      }

      expect(exceptionText, contains('int'));
      expect(exceptionText, contains('test1'));
    });

    test('Throws error on cyclic dependency', () {
      final container = FactoryContainer();
      String exceptionText;

      container.register<String>((c) => 'test1' + c.res<String>(name: 'test2'), name: 'test1');
      container.register<String>((c) => 'test2' + c.res<String>(name: 'test1'), name: 'test2');

      try {
        container.resolve<String>(name: 'test2');
      } catch (e) {
        exceptionText = e.toString();
        expect(e is CyclicDependencyException, true);
      }

      expect(exceptionText, contains('String'));
    });
  });
}
