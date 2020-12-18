import 'package:factory_castle/factory_castle.dart';
import 'package:factory_castle/factory_installer.dart';
import 'package:flutter/material.dart';

import 'counter_service.dart';
import 'ui_text_service.dart';

class ExampleInstaller implements FactoryInstaller {
  @override
  void install(FactoryContainer container) {
    container.register(Component.For((c) => ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        )));

    container.register(Component.For((c) => UiTextService()));
    container.register(Component.For((c) => CounterService()));
  }
}
