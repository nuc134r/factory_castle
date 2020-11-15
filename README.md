# factory_castle

An IoC container for Dart inspired by [Castle Windsor](https://github.com/castleproject/Windsor).

Sample code involving component registration, dependency injection and service locator style resolution:
```dart
final container = FactoryContainer();

container.register(Component.For<ILogger>((c) => Logger('Demo')));
container.register(Component.For((c) => DataRepository(c.resolve())));
container.register(Component.For((c) => ListViewModel(c.resolve(), c.resolve())));

final viewModel = container.resolve<ListViewModel>();

viewModel.update();
```
