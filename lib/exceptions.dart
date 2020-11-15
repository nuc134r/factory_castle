abstract class BaseException {
  final String message;

  BaseException(this.message);

  String toString() => "${this.runtimeType}: $message";
}

class HandlerNotFoundException extends BaseException {
  HandlerNotFoundException(String message) : super(message);
}

class ComponentNotFoundException extends BaseException {
  ComponentNotFoundException(String message) : super(message);
}

class ComponentRegistrationException extends BaseException {
  ComponentRegistrationException(String message) : super(message);
}

class CyclicDependencyException extends BaseException {
  CyclicDependencyException(String message) : super(message);
}
