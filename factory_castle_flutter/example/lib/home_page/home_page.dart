import 'package:factory_castle_flutter/factory_castle_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../ui_text_service.dart';
import 'home_page_model.dart';
import 'increment_button.dart';

class HomePage extends StatelessWidget {
  /// A root of an MVVM component must be a [View] widget.
  @override
  Widget build(BuildContext context) => View<HomePageModel>(
        // This is where ViewModel is created. [c] is a FactoryContainer, use it to inject dependencies.
        // If constructor parameter is already of type that you have registered in container then you don't have to
        // specify it. Dart infers types.
        model: (c) => HomePageModel(c.resolve()),
        builder: (context, model) {
          return Scaffold(
            appBar: AppBar(
              // There are extensions for BuildContext to access the container easily.
              // Service Locator pattern is not a good practice, but let's keep it for the sake of an example.
              title: Text(context.resolve<UiTextService>().homePageTitle),
            ),
            body: Center(
              child: model.isBusy // ViewModelBase already contains a handy isBusy flag to help creating loading screens.
                  ? CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(context.resolve<UiTextService>().pressCounterLabel),
                        Text(
                          model.value.toString(),
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ],
                    ),
            ),
            floatingActionButton: IncrementButton(),
          );
        },
      );
}
