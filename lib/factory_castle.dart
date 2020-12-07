library factory_castle;

import 'dart:collection';

import 'package:factory_castle/exceptions.dart';
import 'package:factory_castle/factory_installer.dart';

/// Factory method.
typedef T Factory<T>(FactoryContainer c);

/// IoC container.
class FactoryContainer {
  void install(FactoryInstaller installer) => installer.install(this);

  void register<T>(Component<T> component) {
    var handler = _handlers[component._type];

    if (handler == null) {
      handler = _ComponentHandler._(component._type, this);
      _handlers[component._type] = handler;
    }

    handler.add(component);
  }

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

  T resolve<T>({String name = ''}) => resolveOfType(T, name: name);

  void attachChildContainer(FactoryContainer container) {
    container._parent = this;
  }

  FactoryContainer _parent;
  HashMap<Type, _ComponentHandler> _handlers = HashMap<Type, _ComponentHandler>();
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
  // ignore: non_constant_identifier_names
  static Component For<T>(Factory<T> factory) => Component._(factory, T);

  Component._(this._factory, this._type);

  Component<T> named(String name) {
    this._name = name;
    return this;
  }

  Component<T> lifestyle(Lifestyle lifestyle) {
    this._lifestyle = lifestyle;
    return this;
  }

  String _name = '';
  Lifestyle _lifestyle = Lifestyle.Singleton;
  T _instance;

  final Type _type;
  final Factory<T> _factory;
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
        return _obtainInstance(_componentsWithoutName.first);
      } else if (_componentsWithName.isNotEmpty) {
        return _obtainInstance(_componentsWithName.values.first);
      } else if (parent != null) {
        return parent.resolveOfType(type);
      } else {
        throw ComponentNotFoundException('Could not resolve component of type "$type"');
      }
    }
  }

  T _obtainInstance(Component<T> component) {
    if (component._lifestyle == Lifestyle.Singleton) {
      return component._instance ??= component._factory(_container);
    }
    if (component._lifestyle == Lifestyle.Transient) {
      return component._factory(_container);
    }
    throw Exception('Unknown component lifestyle ${component._lifestyle}');
  }

  Map<String, Component<T>> _componentsWithName = Map<String, Component<T>>();
  List<Component<T>> _componentsWithoutName = List<Component<T>>();

  final FactoryContainer _container;
}
