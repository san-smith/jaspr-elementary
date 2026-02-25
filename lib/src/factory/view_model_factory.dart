import 'package:jaspr/jaspr.dart';

import '../view_model/view_model.dart';

/// A factory function type used to create an instance of [ViewModel].
///
/// The factory is called once when the [ElementaryElement] is created and
/// inserted into the element tree. The created ViewModel instance lives as
/// long as the element remains in the tree.
///
/// ## Lifecycle
/// - The factory is called when the element is first created
/// - The factory is NOT called when the component is updated
/// - The ViewModel is disposed when the element is removed from the tree
///
/// ## Parameters
/// - [context] — the build context at the location where the ViewModel is created.
///   Can be used to access inherited components or other context-dependent data.
///
/// ## Returns
/// - [T] — an instance of ViewModel parameterized by the component type
///
/// ## Examples
///
/// ### Direct dependency creation
/// ```dart
/// CounterViewModel counterViewModelFactory(BuildContext context) {
///   final repository = CounterRepository();
///   final model = CounterModel(repository);
///   return CounterViewModel(model);
/// }
/// ```
///
/// ### Using a DI container
/// ```dart
/// CounterViewModel counterViewModelFactory(BuildContext context) {
///   final model = getIt<CounterModel>();
///   return CounterViewModel(model);
/// }
/// ```
///
/// ### Getting dependencies from context
/// ```dart
/// CounterViewModel counterViewModelFactory(BuildContext context) {
///   final config = Config.of(context);
///   final model = CounterModel(config.apiEndpoint);
///   return CounterViewModel(model);
/// }
/// ```
///
/// ### Using different factories for testing
/// ```dart
/// // Production factory
/// CounterViewModel counterViewModelFactory(BuildContext context) {
///   return CounterViewModel(CounterModel());
/// }
///
/// // Test factory with mock
/// CounterViewModel counterViewModelFactoryMock(BuildContext context) {
///   return CounterViewModel(MockCounterModel());
/// }
///
/// // Usage in component
/// class CounterComponent extends ElementaryComponent<CounterViewModel> {
///   const CounterComponent({
///     super.key,
///     ViewModelFactory wmFactory = counterViewModelFactory,
///   }) : super(wmFactory);
///
///   // For tests
///   const CounterComponent.test({
///     super.key,
///   }) : super(counterViewModelFactoryMock);
/// }
/// ```
///
/// ## Important notes
///
/// - The factory should create a NEW instance of ViewModel each time it is called
/// - Do not cache or reuse ViewModel instances between factory calls
/// - Each element in the tree gets its own ViewModel instance
/// - The same factory can be used by multiple components, but each will get
///   a separate ViewModel instance
///
/// ## Best practices
///
/// 1. **Keep factories simple** — Delegate complex initialization to the ViewModel
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
///  * [ViewModel], for the base class of presentation logic
///  * [ElementaryComponent], for the component that uses this factory
///  * [BuildContext], for accessing inherited data during ViewModel creation
typedef ViewModelFactory<T extends ViewModel> =
    T Function(BuildContext context);
