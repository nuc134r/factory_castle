import 'package:factory_castle_flutter/factory_castle_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../ui_text_service.dart';
import 'increment_button_model.dart';

class IncrementButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => View<IncrementButtonModel>(
        model: (c) => IncrementButtonModel(c.resolve()),
        builder: (context, model) => FloatingActionButton(
          onPressed: model.isBusy ? null : () => model.increment(),
          tooltip: context.resolve<UiTextService>().incrementButtonTooltip,
          child: model.isBusy ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Icon(Icons.add),
        ),
      );
}
