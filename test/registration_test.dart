import 'package:factory_castle/exceptions.dart';
import 'package:factory_castle/factory_castle.dart';
import 'package:test/test.dart';

void main() {
  group('registration', () {
    test('error contains component type and conflicting name', () {
      final container = FactoryContainer();
      String exceptionText;

      container.register(Component.For((c) => 123)..named('name1'));

      try {
        container.register(Component.For((c) => 321)..named('name1'));
      } catch (e) {
        expect(e is ComponentRegistrationException, true);
        exceptionText = e.toString();
      }

      expect(exceptionText.contains('int'), true);
      expect(exceptionText.contains('name1'), true);
    });

    test('allows registering multiple unnamed components', () {
      final container = FactoryContainer();

      container.register(Component.For((c) => 123));
      container.register(Component.For((c) => 321));
    });
  });
}
