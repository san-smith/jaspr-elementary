/// MVVM architecture for Jaspr applications.
///
/// The `jaspr_elementary` package provides tools for separating business logic
/// and UI in Jaspr applications, following the principles of Flutter Elementary.
///
/// ## Overview
///
/// This package implements the MVVM (Model-View-ViewModel) architecture pattern
/// for Jaspr, making it easy to build maintainable, testable, and scalable
/// web applications. It is designed to be familiar to developers who have used
/// the `elementary` package in Flutter, with minimal changes required to migrate.
///
/// ## Core concepts
///
/// ### Model (Business Logic)
///
/// The [ElementaryModel] contains pure business logic that is independent of
/// the UI. It should not import or depend on Jaspr or any UI framework.
///
/// ```dart
/// class CounterModel extends ElementaryModel {
///   int _count = 0;
///   int get count => _count;
///
///   void increment() {
///     _count++;
///     // Notify UI about the change (via Stream, ChangeNotifier, etc.)
///   }
///
///   @override
///   void dispose() {
///     // Clean up resources (close streams, cancel subscriptions, etc.)
///     super.dispose();
///   }
/// }
/// ```
///
/// ### ViewModel (Presentation Logic)
///
/// The [ViewModel] connects business logic with UI. It manages presentation
/// state and handles user interactions.
///
/// ```dart
/// class CounterViewModel extends ViewModel<CounterComponent, CounterModel> {
///   CounterViewModel(CounterModel model) : super(model);
///
///   int get count => model.count;
///
///   void increment() => model.increment();
///
///   @override
///   void dispose() {
///     // Clean up ViewModel resources
///     super.dispose();
///   }
/// }
/// ```
///
/// ### Component (UI)
///
/// The [ElementaryComponent] describes how to render the UI based on the
/// ViewModel state.
///
/// ```dart
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
/// ## Quick start
///
/// ### Step 1: Create a business logic model
///
/// ```dart
/// class CounterModel extends ElementaryModel {
///   int _count = 0;
///   int get count => _count;
///
///   void increment() {
///     _count++;
///     // Notify UI about the change
///   }
/// }
/// ```
///
/// ### Step 2: Create a ViewModel
///
/// You can use a concrete ViewModel class directly (simpler):
///
/// ```dart
/// class CounterViewModel extends ViewModel<CounterComponent, CounterModel> {
///   CounterViewModel(CounterModel model) : super(model);
///
///   int get count => model.count;
///   void increment() => model.increment();
/// }
/// ```
///
/// Or create an explicit interface for better documentation and testing:
///
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
/// ### Step 3: Create a component
///
/// ```dart
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
///
/// // Factory function
/// CounterViewModel counterViewModelFactory(BuildContext context) {
///   return CounterViewModel(CounterModel());
/// }
/// ```
///
/// ### Step 4: Use the component in your app
///
/// ```dart
/// import 'package:jaspr/jaspr.dart';
/// import 'package:jaspr_elementary/jaspr_elementary.dart';
///
/// void main() {
///   runApp(const MyApp());
/// }
///
/// class MyApp extends StatelessComponent {
///   const MyApp({super.key});
///
///   @override
///   Component build(BuildContext context) {
///     return Component.element(
///       tag: 'body',
///       children: [
///         CounterComponent(),
///       ],
///     );
///   }
/// }
/// ```
///
/// ## Lifecycle
///
/// The ViewModel follows a well-defined lifecycle:
///
/// ```
/// create → initViewModel() → didChangeDependencies() → build()
///                              ↓
///                    didUpdateComponent() (on component update)
///                              ↓
///                         dispose() (on destruction)
/// ```
///
/// ### Lifecycle methods
///
/// | Method | Called when | Purpose |
/// |--------|-------------|---------|
/// | [ViewModel.initViewModel] | Once, before first build | Initialize state, load data |
/// | [ViewModel.didChangeDependencies] | After init, when inherited data changes | React to inherited data |
/// | [ViewModel.didUpdateComponent] | When component configuration changes | React to config changes |
/// | [ViewModel.activate] | When reinserted after deactivate | Resume operations |
/// | [ViewModel.deactivate] | When temporarily removed from tree | Pause operations |
/// | [ViewModel.dispose] | Once, when permanently removed | Clean up resources |
///
/// ## Error handling
///
/// Use [ElementaryModel.handleError] to report errors from business logic:
///
/// ```dart
/// class DataModel extends ElementaryModel {
///   Future<void> fetchData() async {
///     try {
///       final data = await api.getData();
///       // Process data...
///     } catch (error, stackTrace) {
///       handleError(error, stackTrace: stackTrace);
///     }
///   }
/// }
/// ```
///
/// Handle errors in ViewModel:
///
/// ```dart
/// class DataViewModel extends ViewModel<DataComponent, DataModel> {
///   @override
///   void onErrorHandle(Object error) {
///     super.onErrorHandle(error);
///     // Show error to user (snackbar, dialog, etc.)
///     print('Error: $error');
///   }
/// }
/// ```
///
/// ## Reactivity
///
/// This package is reactive-agnostic. You can use any state management approach:
///
/// ### Streams
///
/// ```dart
/// class CounterModel extends ElementaryModel {
///   final _countController = StreamController<int>.broadcast();
///   Stream<int> get countStream => _countController.stream;
///
///   void increment() {
///     _count++;
///     _countController.add(_count);
///   }
///
///   @override
///   void dispose() {
///     _countController.close();
///     super.dispose();
///   }
/// }
///
/// // In component
/// StreamBuilder<int>(
///   stream: vm.countStream,
///   initialData: vm.count,
///   builder: (context, snapshot) {
///     return Component.text('Count: ${snapshot.data}');
///   },
/// )
/// ```
///
/// ### ChangeNotifier
///
/// ```dart
/// class CounterViewModel extends ViewModel<CounterComponent, CounterModel>
///     with ChangeNotifier {
///   void increment() {
///     model.increment();
///     notifyListeners();
///   }
/// }
///
/// // In component
/// ListenableBuilder(
///   listenable: vm,
///   builder: (context) {
///     return Component.text('Count: ${vm.count}');
///   },
/// )
/// ```
///
/// ## Migration from Flutter Elementary
///
/// If you are familiar with the Flutter `elementary` package, here is the
/// mapping between Flutter and Jaspr:
///
/// | Flutter Elementary | Jaspr Elementary |
/// |-------------------|------------------|
/// | `Widget` | `Component` |
/// | `StatefulWidget` | `StatefulComponent` |
/// | `ElementaryWidget` | `ElementaryComponent` |
/// | `WidgetModel` | `ViewModel` |
/// | `IWidgetModel` | `IViewModel` |
/// | `ElementaryModel` | `ElementaryModel` |
/// | `WidgetModelFactory` | `ViewModelFactory` |
/// | `BuildContext` | `BuildContext` |
///
/// ### Code migration example
///
/// **Flutter:**
/// ```dart
/// class CounterWidget extends ElementaryWidget<CounterViewModel> {
///   @override
///   Widget build(CounterViewModel vm) {
///     return Scaffold(
///       body: Text('Count: ${vm.count}'),
///     );
///   }
/// }
/// ```
///
/// **Jaspr:**
/// ```dart
/// class CounterComponent extends ElementaryComponent<CounterViewModel> {
///   @override
///   Component build(CounterViewModel vm) {
///     return Component.element(
///       tag: 'div',
///       children: [Component.text('Count: ${vm.count}')],
///     );
///   }
/// }
/// ```
///
/// ## Best practices
///
/// 1. **Keep models pure** — [ElementaryModel] should not depend on UI frameworks
/// 2. **Use interfaces for large projects** — Create explicit interfaces for
///    better documentation and testing
/// 3. **Clean up resources** — Always dispose of streams, subscriptions, and
///    controllers in [ViewModel.dispose]
/// 4. **Use isMounted** — Check [ViewModel.isMounted] before updating state
///    in async operations
/// 5. **Handle errors centrally** — Use [ElementaryModel.handleError] for
///    consistent error handling
///
/// ## Additional resources
///
/// - [GitHub Repository](https://github.com/san-smith/jaspr_elementary)
/// - [Examples](https://github.com/san-smith/jaspr_elementary/tree/main/example)
/// - [Issue Tracker](https://github.com/san-smith/jaspr_elementary/issues)
///
/// ## Core classes
///
/// - [ElementaryComponent] — Base component for MVVM architecture
/// - [ViewModel] — Base class for presentation logic
/// - [ElementaryModel] — Base class for business logic
/// - [IViewModel] — Base marker interface for all ViewModels
/// - [ViewModelFactory] — Factory function type for creating ViewModels
/// - [ErrorHandler] — Interface for centralized error handling
/// - [ElementaryElement] — Element that manages ViewModel lifecycle (internal)
///
/// ## License
///
/// This package is licensed under the MIT License. See the LICENSE file for
/// details.
library;

export 'src/jaspr_elementary_base.dart';
