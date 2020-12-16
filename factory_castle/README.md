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

As name suggests components are registered as factory deleagates since reflection usage in Dart isn't something you can do easily and in performant way. Each factory delegate recieves `FactoryContainer` as a parameter so that dependencies can be injected into constructor via `resolve()`. Dart is good at type inference so you don't need to explicitly specify dependency types. Types are taken from the called constructor parameters.

See the example:

```dart
container.register(Component.For((c) => ListViewModel(c.resolve(), c.resolve())));
```
