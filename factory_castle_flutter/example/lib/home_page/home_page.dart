import 'package:factory_castle_flutter/factory_castle_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../ui_text_service.dart';
import 'home_page_model.dart';
import 'increment_button.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => View<HomePageModel>(
        model: (c) => HomePageModel(c.resolve()),
        builder: (context, model) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.resolve<UiTextService>().homePageTitle),
            ),
            body: Center(
              child: model.isBusy
                  ? CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          context.resolve<UiTextService>().pressCounterLabel,
                        ),
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
