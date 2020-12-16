library factory_castle_flutter;

import 'package:factory_castle/factory_castle.dart';
import 'package:flutter/widgets.dart';

/// This widget makes [FactoryContainer] available for widgets down the widget tree.
class FactoryContainerWidget extends InheritedWidget {
  FactoryContainerWidget({
    @required this.container,
    @required this.child,
  });

  final FactoryContainer container;
  final Widget child;

  static T resolve<T>(BuildContext context, {String name}) {
    var widget = context.dependOnInheritedWidgetOfExactType<FactoryContainerWidget>();
    return widget.container.resolve(name: name);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  Widget build(BuildContext context) => child;
}
