library factory_castle_flutter;

import 'package:factory_castle/factory_castle.dart';
import 'package:flutter/widgets.dart';

/// Extension methods on [BuildContext] which help working with [FactoryContainer].
extension BuildContextEx on BuildContext {
  /// Returns closest [FactoryContainer] in the widget tree.
  /// [FactoryContainerWidget] must be somewhere on top of widget hierarchy.
  FactoryContainer getContainer() => dependOnInheritedWidgetOfExactType<FactoryContainerWidget>()!.container;

  /// Calls [FactoryContainer.resolve] method on closest [FactoryContainer] in the widget tree.
  /// [FactoryContainerWidget] must be somewhere on top of widget hierarchy.
  T resolve<T>({String name = ''}) => getContainer().resolve<T>(name: name);
}

/// This widget makes [FactoryContainer] available for widgets down the widget tree.
class FactoryContainerWidget extends InheritedWidget {
  FactoryContainerWidget({
    required this.container,
    required this.child,
  }) : super(child: child);

  final FactoryContainer container;
  final Widget child;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  Widget build(BuildContext context) => child;
}

typedef ViewModelBuilder<TModel> = TModel Function(FactoryContainerShort c);
typedef WidgetBuilder<TModel> = Widget Function(BuildContext context, TModel model);

/// Base widget for creating an MVVM view component.
class View<TModel extends ChangeNotifier> extends StatelessWidget {
  View({
    required this.model,
    required this.builder,
    this.doNotDisposeModel = false,
    Key? key,
  }) : super(key: key);

  final ViewModelBuilder<TModel> model;
  final WidgetBuilder<TModel> builder;
  final bool doNotDisposeModel;

  @override
  Widget build(BuildContext context) {
    final viewModel = model(context.getContainer().short);
    return _ViewProxy(
      model: viewModel,
      builder: builder,
      doNotDisposeModel: doNotDisposeModel,
    );
  }
}

class _ViewProxy<TModel extends ChangeNotifier> extends StatefulWidget {
  _ViewProxy({
    required this.model,
    required this.builder,
    required this.doNotDisposeModel,
    Key? key,
  }) : super(key: key);

  final TModel model;
  final WidgetBuilder<TModel> builder;
  final bool doNotDisposeModel;

  @override
  _ViewState createState() {
    if (model is INeedSingleTickerProvider) {
      return _SingleTickerViewState<TModel>(model);
    }

    if (model is INeedTickerProvider) {
      return _TickerViewState<TModel>(model);
    }

    return _ViewState<TModel>(model);
  }
}

class _ViewState<TModel extends ChangeNotifier> extends State<_ViewProxy<TModel>> {
  _ViewState(this._model);

  final TModel _model;

  @override
  void initState() {
    _model.addListener(_onModelChanged);

    if (_model is ViewModelBase) {
      final model = _model as ViewModelBase;
      model.context = context;
      model.onInit();
    }
    super.initState();
  }

  @override
  void dispose() {
    _model.removeListener(_onModelChanged);
    if (!widget.doNotDisposeModel && _model is ViewModelBase) {
      final model = _model as ViewModelBase;
      model._disposed = true;
      model.onDispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _model);

  void _onModelChanged() => setState(() {});
}

class _SingleTickerViewState<TModel extends ChangeNotifier> extends _ViewState<TModel> with SingleTickerProviderStateMixin {
  _SingleTickerViewState(TModel model) : super(model);

  @override
  void initState() {
    final model = widget.model;
    if (model is INeedSingleTickerProvider) {
      model.tickerProvider = this;
    }
    super.initState();
  }
}

class _TickerViewState<TModel extends ChangeNotifier> extends _ViewState<TModel> with TickerProviderStateMixin {
  _TickerViewState(TModel model) : super(model);

  @override
  void initState() {
    final model = widget.model;
    if (model is INeedTickerProvider) {
      model.tickerProvider = this;
    }
    super.initState();
  }
}

/// Base view model used for MVVM.
class ViewModelBase extends ChangeNotifier {
  bool _busy = false;
  bool _hasError = false;
  bool _disposed = false;

  /// Progress state flag to be utilized while building widget.
  bool get isBusy => _busy;

  /// Error state flag to be utilized while building widget.
  bool get hasError => _hasError;

  @protected
  late BuildContext context;

  /// Set [isBusy] flag to true and [hasError] to false, then trigger view widget rebuild.
  void setBusy() {
    _hasError = false;
    _busy = true;

    notifyListeners();
  }

  /// Set [isBusy] flag to false and [hasError] to the specified value, then trigger view widget rebuild.
  void setIdle({required bool hasError}) {
    _hasError = hasError;
    _busy = false;

    notifyListeners();
  }

  /// Trigger widget rebuild. OnPropertyChanged('') analogue.
  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  /// Meant to be overridden to load data on first widget build.
  /// This is called in [State.initState].
  void onInit() {}

  /// Meant to be overridden to unsubscribe from streams, close handles and free resources.
  /// This is called in [State.dispose].
  void onDispose() {}
}

/// Mix this mixin into your view model to obtain [TickerProvider].
/// Backed by [SingleTickerProviderStateMixin].
mixin INeedSingleTickerProvider on ViewModelBase {
  @protected
  late TickerProvider tickerProvider;
}

/// Mix this mixin into your view model to obtain [TickerProvider].
/// Backed by [TickerProviderStateMixin].
mixin INeedTickerProvider on ViewModelBase {
  @protected
  late TickerProvider tickerProvider;
}
