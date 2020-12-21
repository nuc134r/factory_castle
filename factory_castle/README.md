<p align="center">
  <img src="https://raw.githubusercontent.com/nuc134r/factory_castle/master/.github/logo.svg?sanitize=true" width="250px">
</p>

<h3 align="center">IoC container for Dart inspired by <a href="https://github.com/castleproject/Windsor">Castle Windsor</a> + Flutter MVVM framework. </h2>

[![Pub Version](https://img.shields.io/pub/v/factory_castle?color=%23&label=factory_castle)](https://pub.dev/packages/factory_castle)
[![Pub Version](https://img.shields.io/pub/v/factory_castle_flutter?color=%23&label=factory_castle_flutter)](https://pub.dev/packages/factory_castle_flutter)

- [IoC and DI](#ioc-and-di)
  - [Setup](#setup)
  - [Creating container](#creating-container)
  - [Component registration](#component-registration)
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
## Setup

IoC/DI package is platform independent so can be used in both command line apps and Flutter.

Just add it to your `pubspec.yaml`:

```yaml
dependencies:
  factory_castle:
```

## Creating container

```dart
import 'package:factory_castle/factory_castle.dart';

final container = FactoryContainer(); 
```

## Component registration

As name suggests components are registered into container as factory deleagates. You have to manually inject dependencies into constructor (luckily, Dart will help you). 

Reflection could be used to avoid manual injection but sadly `dart:mirrors` library is not available for Flutter. Reflection support for non-Flutter apps may be intorduced later via separate package.

Let's register `MyService` which takes `Logger` and `Config` objects as parameters:
```dart
container.register<MyService>((c) => MyService(c.res<Logger>(), c.res<Config>()));
```

Dart is good at type inference so you don't need to explicitly specify dependency types if they are the same as parameter types. You can also omit registered component type if you don't want to abstract it with any interface.

Next example does exactly the same as previous one:

```dart
container.register((c) => MyService(c.res(), c.res()));
```

Each factory delegate recieves current `FactoryContainer` instance as a parameter so that dependencies can be injected into constructor via `resolve<>()` method. 

Components are resolved lazily so the order of registration is not important. See the full example:

```dart
container.register((c) => MyService(c.res(), c.res()));
container.register((c) => Logger());
container.register((c) => Config(String.fromEnvironment('Flavor')));
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
