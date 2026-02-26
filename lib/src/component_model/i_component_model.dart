/// A base interface for all ComponentModels.
///
/// [IComponentModel] is a marker interface that serves as a type constraint for
/// [ElementaryComponent]. It does not require any methods to be implemented
/// and is used primarily for type safety and documentation purposes.
///
/// ## Purpose
///
/// This interface exists to:
///
/// 1. **Type safety** — Ensures that only valid ComponentModel types can be used
///    with [ElementaryComponent].
///
/// 2. **Documentation** — Makes the API clearer by explicitly showing which
///    types are intended to be used as ComponentModels.
///
/// 3. **Flexibility** — Allows developers to choose between using a specific
///    ComponentModel class directly or creating an explicit interface for their
///    component.
///
/// ## Usage
///
/// ### Without interface (simpler)
///
/// You can use a concrete ComponentModel class directly without creating a separate
/// interface. This is recommended for smaller projects or when the ComponentModel
/// is only used by a single component.
///
/// ```dart
/// class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel> {
///   CounterComponentModel(CounterModel model) : super(model);
///
///   int get count => model.count;
///   void increment() => model.increment();
/// }
///
/// class CounterComponent extends ElementaryComponent<CounterComponentModel> {
///   const CounterComponent({
///     super.key,
///     ComponentModelFactory cmFactory = counterComponentModelFactory,
///   }) : super(cmFactory);
///
///   @override
///   Component build(CounterComponentModel cm) {
///     return Component.element(
///       tag: 'div',
///       children: [
///         Component.text('Count: ${cm.count}'),
///         Component.element(
///           tag: 'button',
///           events: {'click': (_) => cm.increment()},
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
/// between ComponentModel and Component, you can create an interface that extends
/// [IComponentModel].
///
/// ```dart
/// // Define the interface
/// abstract interface class ICounterComponentModel extends IComponentModel {
///   int get count;
///   void increment();
/// }
///
/// // Implement the interface
/// class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel>
///     implements ICounterComponentModel {
///   CounterComponentModel(CounterModel model) : super(model);
///
///   @override
///   int get count => model.count;
///
///   @override
///   void increment() => model.increment();
/// }
///
/// // Use the interface in the component
/// class CounterComponent extends ElementaryComponent<ICounterComponentModel> {
///   const CounterComponent({
///     super.key,
///     ComponentModelFactory cmFactory = counterComponentModelFactory,
///   }) : super(cmFactory);
///
///   @override
///   Component build(ICounterComponentModel cm) {
///     return Component.element(
///       tag: 'div',
///       children: [
///         Component.text('Count: ${cm.count}'),
///         Component.element(
///           tag: 'button',
///           events: {'click': (_) => cm.increment()},
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
/// | Need to mock ComponentModel for tests | Interface useful |
/// | Public component package | Interface documents API |
/// | Single component uses ComponentModel | No interface needed |
/// | Multiple components share ComponentModel | Interface recommended |
///
/// ## Benefits of using an interface
///
/// 1. **Explicit contract** — Clearly documents what data and methods the
///    component expects from the ComponentModel.
///
/// 2. **Easier testing** — You can create mock implementations of the interface
///    for unit testing the component without needing the full ComponentModel.
///
/// 3. **Refactoring safety** — If you need to change the ComponentModel implementation,
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
/// abstract interface class IExampleComponentModel extends IComponentModel {
///   // ...
/// }
/// ```
///
/// ## Important notes
///
/// - This interface is optional. You are not required to create an interface
///   for every ComponentModel.
/// - All classes that extend [ComponentModel] automatically implement [IComponentModel].
/// - The interface does not require any methods to be implemented.
///
/// See also:
///
///  * [ComponentModel], for the base class that implements this interface
///  * [ElementaryComponent], for the component that uses this interface as a type constraint
///  * [ElementaryModel], for the business logic layer that ComponentModel depends on
abstract interface class IComponentModel {}
