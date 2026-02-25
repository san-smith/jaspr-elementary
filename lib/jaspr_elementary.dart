/// Пакет jaspr_elementary — MVVM архитектура для Jaspr.
///
/// Этот пакет предоставляет инструменты для разделения бизнес-логики
/// и UI в приложениях на Jaspr, следуя принципам Flutter Elementary.
///
/// ## Быстрый старт
///
/// ### 1. Создайте модель бизнес-логики
/// ```dart
/// class CounterModel extends ElementaryModel {
///   int _count = 0;
///   int get count => _count;
///
///   void increment() {
///     _count++;
///     // Уведомите UI об изменении
///   }
/// }
/// ```
///
/// ### 2. Создайте ViewModel
/// ```dart
/// abstract interface class ICounterViewModel extends IViewModel {
///   int get count;
///   void increment();
/// }
///
/// class CounterViewModel extends ViewModel<CounterComponent, CounterModel>
///     implements ICounterViewModel {
///   CounterViewModel(CounterModel model) : super(model);
///
///   @override
///   int get count => model.count;
///
///   @override
///   void increment() => model.increment();
/// }
/// ```
///
/// ### 3. Создайте компонент
/// ```dart
/// class CounterComponent extends ElementaryComponent<ICounterViewModel> {
///   const CounterComponent({
///     super.key,
///     ViewModelFactory wmFactory = counterViewModelFactory,
///   }) : super(wmFactory);
///
///   @override
///   Component build(ICounterViewModel vm) {
///     return div(children: [
///       p(text: 'Count: ${vm.count}'),
///       button(text: '+', onClick: (_) => vm.increment()),
///     ]);
///   }
/// }
/// ```
///
/// ## Дополнительные ресурсы
/// - [GitHub Repository](https://github.com/san-smith/jaspr_elementary)
/// - [Примеры использования](https://github.com/san-smith/jaspr_elementary/tree/main/example)
library;

export 'src/jaspr_elementary_base.dart';
