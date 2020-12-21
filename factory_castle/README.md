<p align="center">
  <img src="https://raw.githubusercontent.com/nuc134r/factory_castle/master/.github/logo.svg?sanitize=true" width="250px">
</p>

<h3 align="center">IoC container for Dart inspired by <a href="https://github.com/castleproject/Windsor">Castle Windsor</a> + Flutter MVVM framework. </h2>

Table of contents:
- [IoC and DI](#ioc-and-di)
  - [Basics](#basics)
  - [Lifestyles](#lifestyles)
  - [Names](#names)
  - [Component overrides](#component-overrides)
  - [Container hierarchy](#container-hierarchy)
- [Flutter state management and MVVM](#flutter-state-management-and-mvvm)
  - [Root widget](#root-widget)
  - [View](#view)
  - [ViewModel](#viewmodel)
  - [Tips and tricks](#tips-and-tricks)
  - [Example](#example)

# IoC and DI
## Basics

As name suggests components are registered to container as factory deleagates. Reflection usage in Dart is not particularly legal (at least with Flutter). 

Each factory delegate recieves `FactoryContainer` as a parameter so that dependencies can be injected into constructor via `resolve<>()`. Dart is good at type inference so you don't need to explicitly specify dependency types if they are the same as parameter types. Components are resolved lazily so the order of registration is not important.

See the example:

```dart
// Registration of a component for ListViewModel. 
// When component is being created two dependencies of types that correspond with 
// constructor params will be also resolved from the container.
container.register(Component.For((c) => ListViewModel(c.resolve(), c.resolve())));
```

Sample code involving component registration, dependency injection and service locator style resolution:

```dart
// creating container is straighforward
final container = FactoryContainer();

// register a couple components that depend on each other
container.register(Component.For<ILogger>((c) => Logger('Demo')));
container.register(Component.For((c) => DataRepository(c.resolve())));
container.register(Component.For((c) => ListViewModel(c.resolve(), c.resolve())));

// get a component from the container
final viewModel = container.resolve<ListViewModel>();

// use it
viewModel.update();
```
## Lifestyles
## Names
## Component overrides
## Container hierarchy
# Flutter state management and MVVM
## Root widget
## View
## ViewModel
## Tips and tricks
## Example
