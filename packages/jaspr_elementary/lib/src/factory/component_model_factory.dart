import 'package:jaspr/jaspr.dart';

import '../component_model/component_model.dart';

/// A factory function type used to create an instance of [ComponentModel].
///
/// The factory is called once when the [ElementaryElement] is created and
/// inserted into the element tree. The created ComponentModel instance lives as
/// long as the element remains in the tree.
///
/// ## Lifecycle
/// - The factory is called when the element is first created
/// - The factory is NOT called when the component is updated
/// - The ComponentModel is disposed when the element is removed from the tree
///
/// ## Parameters
/// - [context] — the build context at the location where the ComponentModel is created.
///   Can be used to access inherited components or other context-dependent data.
///
/// ## Returns
/// - [T] — an instance of ComponentModel parameterized by the component type
///
/// ## Examples
///
/// ### Direct dependency creation
/// ```dart
/// CounterComponentModel counterComponentModelFactory(BuildContext context) {
///   final repository = CounterRepository();
///   final model = CounterModel(repository);
///   return CounterComponentModel(model);
/// }
/// ```
///
/// ### Using a DI container
/// ```dart
/// CounterComponentModel counterComponentModelFactory(BuildContext context) {
///   final model = getIt<CounterModel>();
///   return CounterComponentModel(model);
/// }
/// ```
///
/// ### Getting dependencies from context
/// ```dart
/// CounterComponentModel counterComponentModelFactory(BuildContext context) {
///   final config = Config.of(context);
///   final model = CounterModel(config.apiEndpoint);
///   return CounterComponentModel(model);
/// }
/// ```
///
/// ### Using different factories for testing
/// ```dart
/// // Production factory
/// CounterComponentModel counterComponentModelFactory(BuildContext context) {
///   return CounterComponentModel(CounterModel());
/// }
///
/// // Test factory with mock
/// CounterComponentModel counterComponentModelFactoryMock(BuildContext context) {
///   return CounterComponentModel(MockCounterModel());
/// }
///
/// // Usage in component
/// class CounterComponent extends ElementaryComponent<CounterComponentModel> {
///   const CounterComponent({
///     super.key,
///     ComponentModelFactory cmFactory = counterComponentModelFactory,
///   }) : super(cmFactory);
///
///   // For tests
///   const CounterComponent.test({
///     super.key,
///   }) : super(counterComponentModelFactoryMock);
/// }
/// ```
///
/// ## Important notes
///
/// - The factory should create a NEW instance of ComponentModel each time it is called
/// - Do not cache or reuse ComponentModel instances between factory calls
/// - Each element in the tree gets its own ComponentModel instance
/// - The same factory can be used by multiple components, but each will get
///   a separate ComponentModel instance
///
/// ## Best practices
///
/// 1. **Keep factories simple** — Delegate complex initialization to the ComponentModel
///    constructor or a separate builder class.
///
/// 2. **Use dependency injection** — For production apps, consider using a DI
///    container (like `get_it` or `riverpod`) to manage dependencies.
///
/// 3. **Make factories overridable** — Allow consumers of your components to
///    provide custom factories for testing or customization.
///
/// 4. **Document dependencies** — If your factory requires specific inherited
///    components or context data, document this clearly.
///
/// See also:
///
///  * [ComponentModel], for the base class of presentation logic
///  * [ElementaryComponent], for the component that uses this factory
///  * [BuildContext], for accessing inherited data during ComponentModel creation
typedef ComponentModelFactory<T extends ComponentModel> =
    T Function(BuildContext context);
