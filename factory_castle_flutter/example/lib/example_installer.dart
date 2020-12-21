import 'package:factory_castle/factory_castle.dart';
import 'package:factory_castle/factory_installer.dart';
import 'package:flutter/material.dart';

import 'counter_service.dart';
import 'ui_text_service.dart';

class ExampleInstaller implements FactoryInstaller {
  @override
  void install(FactoryContainer container) {
    container.register<ThemeData>((c) => _buildTheme());
    container.register<UiTextService>((c) => UiTextService());
    // Component type can be omitted if it is the same as the implementation. Dart is good at guessing it.
    container.register((c) => CounterService());
  }

  ThemeData _buildTheme() => ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
}
