/// A base interface for all ViewModels.
///
/// [IViewModel] is a marker interface that serves as a type constraint for
/// [ElementaryComponent]. It does not require any methods to be implemented
/// and is used primarily for type safety and documentation purposes.
///
/// ## Purpose
///
/// This interface exists to:
///
/// 1. **Type safety** — Ensures that only valid ViewModel types can be used
///    with [ElementaryComponent].
///
/// 2. **Documentation** — Makes the API clearer by explicitly showing which
///    types are intended to be used as ViewModels.
///
/// 3. **Flexibility** — Allows developers to choose between using a specific
///    ViewModel class directly or creating an explicit interface for their
///    component.
///
/// ## Usage
///
/// ### Without interface (simpler)
///
/// You can use a concrete ViewModel class directly without creating a separate
/// interface. This is recommended for smaller projects or when the ViewModel
/// is only used by a single component.
///
/// ```dart
/// class CounterViewModel extends ViewModel<CounterComponent, CounterModel> {
///   CounterViewModel(CounterModel model) : super(model);
///
///   int get count => model.count;
///   void increment() => model.increment();
/// }
///
/// class CounterComponent extends ElementaryComponent<CounterViewModel> {
///   const CounterComponent({
///     super.key,
///     ViewModelFactory wmFactory = counterViewModelFactory,
///   }) : super(wmFactory);
///
///   @override
///   Component build(CounterViewModel vm) {
///     return Component.element(
///       tag: 'div',
///       children: [
///         Component.text('Count: ${vm.count}'),
///         Component.element(
///           tag: 'button',
///           events: {'click': (_) => vm.increment()},
///           children: [Component.text('+')],
///         ),
///       ],
///     );
///   }
/// }
/// ```
///
/// ### With interface (more explicit)
///
/// For larger projects or when you want to explicitly document the contract
/// between ViewModel and Component, you can create an interface that extends
/// [IViewModel].
///
/// ```dart
/// // Define the interface
/// abstract interface class ICounterViewModel extends IViewModel {
///   int get count;
///   void increment();
/// }
///
/// // Implement the interface
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
///
/// // Use the interface in the component
/// class CounterComponent extends ElementaryComponent<ICounterViewModel> {
///   const CounterComponent({
///     super.key,
///     ViewModelFactory wmFactory = counterViewModelFactory,
///   }) : super(wmFactory);
///
///   @override
///   Component build(ICounterViewModel vm) {
///     return Component.element(
///       tag: 'div',
///       children: [
///         Component.text('Count: ${vm.count}'),
///         Component.element(
///           tag: 'button',
///           events: {'click': (_) => vm.increment()},
///           children: [Component.text('+')],
///         ),
///       ],
///     );
///   }
/// }
/// ```
///
/// ## When to use an interface
///
/// | Situation | Recommendation |
/// |-----------|----------------|
/// | Small project or prototype | No interface needed |
/// | Large project with team | Interface recommended |
/// | Need to mock ViewModel for tests | Interface useful |
/// | Public component package | Interface documents API |
/// | Single component uses ViewModel | No interface needed |
/// | Multiple components share ViewModel | Interface recommended |
///
/// ## Benefits of using an interface
///
/// 1. **Explicit contract** — Clearly documents what data and methods the
///    component expects from the ViewModel.
///
/// 2. **Easier testing** — You can create mock implementations of the interface
///    for unit testing the component without needing the full ViewModel.
///
/// 3. **Refactoring safety** — If you need to change the ViewModel implementation,
///    the interface acts as a stable contract that components depend on.
///
/// 4. **Better IDE support** — Interfaces provide clearer autocomplete and
///    navigation in IDEs.
///
/// ## Migration from Flutter Elementary
///
/// If you are familiar with the Flutter `elementary` package, this interface
/// is equivalent to `IWidgetModel`:
///
/// ```dart
/// // Flutter elementary
/// abstract interface class IExampleWidgetModel extends IWidgetModel {
///   // ...
/// }
///
/// // Jaspr elementary
/// abstract interface class IExampleViewModel extends IViewModel {
///   // ...
/// }
/// ```
///
/// ## Important notes
///
/// - This interface is optional. You are not required to create an interface
///   for every ViewModel.
/// - All classes that extend [ViewModel] automatically implement [IViewModel].
/// - The interface does not require any methods to be implemented.
///
/// See also:
///
///  * [ViewModel], for the base class that implements this interface
///  * [ElementaryComponent], for the component that uses this interface as a type constraint
///  * [ElementaryModel], for the business logic layer that ViewModel depends on
abstract interface class IViewModel {}
