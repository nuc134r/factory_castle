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
    final component = _Handler._(factory, T, name, lifestyle);
    var handler = _handlers[component._type];

    if (handler == null) {
      handler = _HandlerCollection._(component._type, this);
      _handlers[component._type] = handler;
    }

    handler.add(component);
  }

  /// Resolve a dependency of a runtime obtained type.
  dynamic resolveOfType(Type type, {String name, bool all = false}) {
    if (all == true && (name != null && name.isNotEmpty)) {
      throw UnsupportedError('Cannot request multiple components of type ${type.toString()} by name. Name was "$name".');
    }

    final handler = _handlers[type];

    if (handler == null) {
      if (_parent != null) {
        return _parent.resolveOfType(type, name: name, all: all);
      }
      if (name != null && name.isNotEmpty) {
        throw HandlerNotFoundException('Handler not found for ${type.toString()} and name "$name"');
      } else {
        throw HandlerNotFoundException('Handler not found for ${type.toString()}');
      }
    }

    try {
      return handler.get(name, _parent, all);
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

  List<T> resolveAll<T>() => resolveOfType(T, all: true).cast<T>();

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
  HashMap<Type, _HandlerCollection> _handlers = HashMap<Type, _HandlerCollection>();
}

/// Shortened syntax version of [FactoryContainer] for convenience use in factory delegates.
class FactoryContainerShort {
  FactoryContainerShort(this.container);

  /// Resolve component by type and name.
  T res<T>({String name = ''}) => container.resolve<T>(name: name);

  /// Resolve all components by type.
  List<T> all<T>() => container.resolveAll<T>();

  /// Wrapped container.
  final FactoryContainer container;
}

/// Component lifestyle.
enum Lifestyle {
  /// Same instance is returned on every [resolve] call. This is default lifestyle.
  /// Component is instantiated on first resolution.
  Singleton,

  /// New object is instantiated on every [resolve] call.
  Transient,
}

class _Handler<T> {
  _Handler._(this._factory, this._type, this._name, this._lifestyle);

  T _instance;

  final String _name;
  final Lifestyle _lifestyle;
  final Type _type;
  final FactoryDelegate<T> _factory;
}

class _HandlerCollection<T> {
  _HandlerCollection._(this.type, this._container);

  final Type type;

  void add(_Handler<T> component) {
    if (component._name.isEmpty) {
      _unnamedHandlers.add(component);
    } else {
      if (_namedHandlers.containsKey(component._name)) {
        throw ComponentRegistrationException('Component of type "$type" under name "${component._name}" already registered');
      }

      _namedHandlers.putIfAbsent(component._name, () => component);
    }
  }

  dynamic get(String name, FactoryContainer parent, bool all) {
    if (name != null && name.isNotEmpty) {
      if (_namedHandlers.containsKey(name)) {
        return _obtainInstance(_namedHandlers[name]);
      } else {
        if (parent != null) {
          return parent.resolveOfType(type, name: name);
        }
        throw ComponentNotFoundException('Could not resolve named component of type "$type" under name $name');
      }
    } else {
      if (all == true) {
        return [
          ..._namedHandlers.entries.map((e) => _obtainInstance(e.value)),
          ..._unnamedHandlers.map((e) => _obtainInstance(e)),
        ];
      }

      if (_unnamedHandlers.isNotEmpty) {
        return _obtainInstance(_unnamedHandlers.last);
      } else if (_namedHandlers.isNotEmpty) {
        return _obtainInstance(_namedHandlers.values.last);
      } else if (parent != null) {
        return parent.resolveOfType(type);
      } else {
        throw ComponentNotFoundException('Could not resolve component of type "$type"');
      }
    }
  }

  T _obtainInstance(_Handler<T> component) {
    if (component._lifestyle == Lifestyle.Singleton) {
      return component._instance ??= component._factory(_container.short);
    }
    if (component._lifestyle == Lifestyle.Transient) {
      return component._factory(_container.short);
    }
    throw Exception('Unknown component lifestyle ${component._lifestyle}');
  }

  Map<String, _Handler<T>> _namedHandlers = Map<String, _Handler<T>>();
  List<_Handler<T>> _unnamedHandlers = List<_Handler<T>>();

  final FactoryContainer _container;
}
