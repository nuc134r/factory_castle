<p align="center">
  <img src="https://raw.githubusercontent.com/nuc134r/factory_castle/master/.github/logo.svg?sanitize=true" width="250px">
</p>

<h3 align="center">IoC container for Dart inspired by <a href="https://github.com/castleproject/Windsor">Castle Windsor</a> + Flutter MVVM framework. </h2>

[![Pub Version](https://img.shields.io/pub/v/factory_castle?color=%23&label=factory_castle)](https://pub.dev/packages/factory_castle)
[![Pub Version](https://img.shields.io/pub/v/factory_castle_flutter?color=%23&label=factory_castle_flutter)](https://pub.dev/packages/factory_castle_flutter)
![test](https://github.com/nuc134r/factory_castle/workflows/test/badge.svg)
[![codecov](https://codecov.io/gh/nuc134r/factory_castle/branch/main/graph/badge.svg?token=4QGMFOZYRW)](https://codecov.io/gh/nuc134r/factory_castle)

- [IoC and DI](#ioc-and-di)
  - [Setup](#setup)
  - [Creating container](#creating-container)
  - [Component registration](#component-registration)
  - [Obtain components](#obtain-components)
  - [Lifestyles](#lifestyles)
    - [Singleton](#singleton)
    - [Transient](#transient)
  - [Names](#names)
  - [Component overrides](#component-overrides)
  - [Container disposal](#container-disposal)
  - [Container hierarchy](#container-hierarchy)
- [Flutter state management and MVVM](#flutter-state-management-and-mvvm)
  - [Root widget](#root-widget)
  - [View](#view)
  - [ViewModel](#viewmodel)
  - [Service Locator](#service-locator)
  - [Obtaining TickerProvider](#obtaining-tickerprovider)
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

Each factory delegate recieves shorthand wrapper for current `FactoryContainer` instance as a parameter so that dependencies can be injected into constructor via `res<>()` method. 

Components are resolved lazily which makes the order of registration not important. See the full example:

```dart
container.register((c) => MyService(c.res(), c.res()));
container.register((c) => Logger());
container.register((c) => Config(String.fromEnvironment('Flavor')));
```

Registering components under multiple interfaces is not supported yet. The following workaround is suggested:

```dart
final logger = FileLogger();
container.register<ILogger>((c) => logger);
container.register<Logger>((c) => logger);
```

## Obtain components

Call `FactoryContainer.resolve<>()` with component type to obtain it from container.

```dart
final repo = container.resolve<UserRepository>();
```

## Lifestyles

Component lifecycle can be specified via optional parameter in `FactoryContainer.register()`:

```dart
container.register((c) => CacheEntry(c.res(), c.res()), lifestyle: Lifestyle.Transient);
```

Currently two lifecycle options are available.

### Singleton
Component's factory delegate is called once on first `resolve<>()`. Same instance is returned on every subsequent call. This is default lifestyle.

### Transient

Component's factory delegate is called on every `resolve<>()` call. There is no way to specify dynamic parameters yet.

## Names

You can specify component name so that this exact component is resolved when needed.

```dart
container.register<ILogger>((c) => DbLogger(), name: 'DbLogger');
container.register<ILogger>((c) => FileLogger(), name: 'FileLogger');

// ...

final fileLog = container.resolve<ILogger>(name: 'FileLogger');
```

## Component overrides

By default every unnamed registered component overrides previous. That is not a final design and can be changed in future. For now you can register multiple unnamed components and expect to get last one on `resolve<>()`.

```dart
container.register<ICacheFactory>((c) => DefaultCacheFactory());
container.register<ICacheFactory>((c) => MyCacheFactory());

final cacheFactory = container.resolve<ICacheFactory>(); // MyCacheFactory
```

This behaviour is not consistent when both named and unnamed components are registered.

## Container disposal

Container and component disposal is not yet implemented.

## Container hierarchy
# Flutter state management and MVVM
## Root widget
## View
## ViewModel
## Service Locator
## Obtaining TickerProvider
## Example
