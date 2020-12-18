import 'package:factory_castle/factory_castle.dart';
import 'package:factory_castle_flutter/factory_castle_flutter.dart';
import 'package:flutter/material.dart';

import 'example_installer.dart';
import 'home_page/home_page.dart';
import 'ui_text_service.dart';

/// IoC container is set up via installer before the app is run.
void main() {
  final container = FactoryContainer()..install(ExampleInstaller());
  runApp(MyApp(container));
}

class MyApp extends StatelessWidget {
  MyApp(this._container);

  final FactoryContainer _container;

  /// App root is [FactoryContainerWidget] which makes [FactoryContainer] accessible down the widget tree
  @override
  Widget build(BuildContext context) => FactoryContainerWidget(
        container: _container,
        child: MaterialApp(
          title: _container.resolve<UiTextService>().appTitle,
          theme: _container.resolve(),
          home: HomePage(),
        ),
      );
}
