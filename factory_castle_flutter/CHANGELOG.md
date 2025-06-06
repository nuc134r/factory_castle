## 3.2.0 (07.06.2025)
* Added `View.doNotDisposeModel` flag to prevent automatic disposal of the model when the view is disposed. This is useful when view models are reused instead of created on every view appearance.

## 3.1.0 (13.06.2022)
* `INeedTickerProvider` mixin now corresponds to `TickerProviderStateMixin` instead of `SingleTickerProviderStateMixin`
* `INeedSingleTickerProvider` mixin added to allow usage of `SingleTickerProviderStateMixin`

## 3.0.0 (04.06.2022)
* Null safety

## 2.1.0
* Added INeedTickerProvider mixin for ViewModelBase

## 2.0.1
* Using shorthand container wrapper for view model builder

## 2.0.0
* Update to factory_castle 2.0.0

## 1.0.1
* MVVM base classes and helpers

## 1.0.0
* Initial release
