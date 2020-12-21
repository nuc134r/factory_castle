library factory_castle;

import 'dart:collection';

import 'package:factory_castle/exceptions.dart';
import 'package:factory_castle/factory_installer.dart';

/// Factory delegate.
typedef FactoryDelegate<T> = T Function(FactoryContainerShort c);

/// IoC container.
class FactoryContainer {
  /// Install an installer into this container.
  void install(FactoryInstaller installer) => installer.install(this);

  /// Register a component of specified type using factory delegate.
  void register<T>(FactoryDelegate<T> factory, {String name = '', Lifestyle lifestyle = Lifestyle.Singleton}) {
    final component = Component._(factory, T)
      ..named(name)
      ..lifestyle(lifestyle);
    var handler = _handlers[component._type];

    if (handler == null) {
      handler = _ComponentHandler._(component._type, this);
      _handlers[component._type] = handler;
    }

    handler.add(component);
  }

  /// Resolve a dependency of a runtime obtained type.
  dynamic resolveOfType(Type type, {String name}) {
    final handler = _handlers[type];

    if (handler == null) {
      if (_parent != null) {
        return _parent.resolveOfType(type, name: name);
      }
      throw HandlerNotFoundException('Handler not found for "${type.toString()}"');
    }
    try {
      return handler.get(name, _parent);
    } catch (e) {
      if (e.toString().contains('Stack Overflow')) {
        if (name != null && name.isNotEmpty) {
          throw CyclicDependencyException(
              'Stack Overflow exception occured which may be a sign of cyclic dependency. Exception occured while resolving component of type ${type.toString()} with name "$name"');
        } else {
          throw CyclicDependencyException(
              'Stack Overflow exception occured which may be a sign of cyclic dependency. Exception occured while resolving component of type ${type.toString()}');
        }
      } else {
        rethrow;
      }
    }
  }

  /// Resolve component by type and name.
  T resolve<T>({String name = ''}) => resolveOfType(T, name: name);

  /// Attach a child container to this container.
  void attachChildContainer(FactoryContainer container) {
    if (identical(this, container)) {
      throw UnsupportedError('Cannot attach a container to itself as a child container');
    }
    container._parent = this;
  }

  /// Shortened syntax version of [FactoryContainer] for convenience use in factory delegates.
  FactoryContainerShort get short => _short ??= FactoryContainerShort(this);

  FactoryContainer _parent;
  FactoryContainerShort _short;
  HashMap<Type, _ComponentHandler> _handlers = HashMap<Type, _ComponentHandler>();
}

/// Shortened syntax version of [FactoryContainer] for convenience use in factory delegates.
class FactoryContainerShort {
  FactoryContainerShort(this.container);

  /// Resolve component by type and name.
  T res<T>({String name = ''}) => container.resolve<T>(name: name);

  /// Wrapped container.
  final FactoryContainer container;
}

/// Component lifestyle.
enum Lifestyle {
  /// Same instance is returned on every [resolve] call.
  /// Component is instantiated on first resolution.
  Singleton,

  /// New object is instantiated on every [resolve] call.
  Transient,
}

/// Component holder with fluent API.
class Component<T> {
  Component._(this._factory, this._type);

  /// Specify a name for this component.
  Component<T> named(String name) {
    this._name = name;
    return this;
  }

  /// Specify a lifestyle for this component.
  Component<T> lifestyle(Lifestyle lifestyle) {
    this._lifestyle = lifestyle;
    return this;
  }

  String _name = '';
  Lifestyle _lifestyle = Lifestyle.Singleton;
  T _instance;

  final Type _type;
  final FactoryDelegate<T> _factory;
}

class _ComponentHandler<T> {
  _ComponentHandler._(this.type, this._container);

  final Type type;

  void add(Component<T> component) {
    if (component._name.isEmpty) {
      _componentsWithoutName.add(component);
    } else {
      if (_componentsWithName.containsKey(component._name)) {
        throw ComponentRegistrationException('Component of type "$type" under name "${component._name}" already registered');
      }

      _componentsWithName.putIfAbsent(component._name, () => component);
    }
  }

  T get(String name, FactoryContainer parent) {
    if (name != null && name.isNotEmpty) {
      if (_componentsWithName.containsKey(name)) {
        return _obtainInstance(_componentsWithName[name]);
      } else {
        if (parent != null) {
          return parent.resolveOfType(type, name: name);
        }
        throw ComponentNotFoundException('Could not resolve named component of type "$type" under name $name');
      }
    } else {
      if (_componentsWithoutName.isNotEmpty) {
        return _obtainInstance(_componentsWithoutName.last);
      } else if (_componentsWithName.isNotEmpty) {
        return _obtainInstance(_componentsWithName.values.last);
      } else if (parent != null) {
        return parent.resolveOfType(type);
      } else {
        throw ComponentNotFoundException('Could not resolve component of type "$type"');
      }
    }
  }

  T _obtainInstance(Component<T> component) {
    if (component._lifestyle == Lifestyle.Singleton) {
      return component._instance ??= component._factory(_container.short);
    }
    if (component._lifestyle == Lifestyle.Transient) {
      return component._factory(_container.short);
    }
    throw Exception('Unknown component lifestyle ${component._lifestyle}');
  }

  Map<String, Component<T>> _componentsWithName = Map<String, Component<T>>();
  List<Component<T>> _componentsWithoutName = List<Component<T>>();

  final FactoryContainer _container;
}
