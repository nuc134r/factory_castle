import 'package:factory_castle_flutter/factory_castle_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../ui_text_service.dart';
import 'increment_button_model.dart';

/// This button is extracted from the page to demonstrate how global state ([CounterService])
/// can be easily delivered to smallest components' view models.
///
/// Button is independent from the page and can be reused.
class IncrementButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => View<IncrementButtonModel>(
        model: (c) => IncrementButtonModel(c.res()),
        builder: (context, model) => FloatingActionButton(
          // ViewModelBase.isBusy flag allows button to become inactive and show progress
          // indicator while it's action is being asyncroniously performed.
          onPressed: model.isBusy ? null : () => model.increment(),
          child: model.isBusy ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Icon(Icons.add),

          tooltip: context.resolve<UiTextService>().incrementButtonTooltip,

          backgroundColor: model.colorAnimation.value,
        ),
      );
}
