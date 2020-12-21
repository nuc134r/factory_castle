import 'package:factory_castle/exceptions.dart';
import 'package:factory_castle/factory_castle.dart';
import 'package:test/test.dart';

void main() {
  group('registration', () {
    test('error contains component type and conflicting name', () {
      final container = FactoryContainer();
      String exceptionText;

      container.register((c) => 123, name: 'name1');

      try {
        container.register((c) => 321, name: 'name1');
      } catch (e) {
        expect(e is ComponentRegistrationException, true);
        exceptionText = e.toString();
      }

      expect(exceptionText.contains('int'), true);
      expect(exceptionText.contains('name1'), true);
    });

    test('allows registering multiple unnamed components', () {
      final container = FactoryContainer();

      container.register((c) => 123);
      container.register((c) => 321);
    });
  });
}
