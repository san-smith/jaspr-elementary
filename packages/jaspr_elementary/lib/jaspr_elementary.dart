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
/// ### ComponentModel (Presentation Logic)
///
/// The [ComponentModel] connects business logic with UI. It manages presentation
/// state and handles user interactions.
///
/// ```dart
/// class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel> {
///   CounterComponentModel(CounterModel model) : super(model);
///
///   int get count => model.count;
///
///   void increment() => model.increment();
///
///   @override
///   void dispose() {
///     // Clean up ComponentModel resources
///     super.dispose();
///   }
/// }
/// ```
///
/// ### Component (UI)
///
/// The [ElementaryComponent] describes how to render the UI based on the
/// ComponentModel state.
///
/// ```dart
/// class CounterComponent extends ElementaryComponent<CounterComponentModel> {
///   const CounterComponent({
///     super.key,
///     ComponentModelFactory cmFactory = counterVComponentModelFactory,
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
/// ### Step 2: Create a ComponentModel
///
/// You can use a concrete ComponentModel class directly (simpler):
///
/// ```dart
/// class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel> {
///   CounterComponentModel(CounterModel model) : super(model);
///
///   int get count => model.count;
///   void increment() => model.increment();
/// }
/// ```
///
/// Or create an explicit interface for better documentation and testing:
///
/// ```dart
/// abstract interface class ICounterComponentModel extends IComponentModel {
///   int get count;
///   void increment();
/// }
///
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
/// ```
///
/// ### Step 3: Create a component
///
/// ```dart
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
///
/// // Factory function
/// CounterComponentModel counterComponentModelFactory(BuildContext context) {
///   return CounterComponentModel(CounterModel());
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
/// The ComponentModel follows a well-defined lifecycle:
///
/// ```
/// create → initComponentModel() → didChangeDependencies() → build()
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
/// | [ComponentModel.initComponentModel] | Once, before first build | Initialize state, load data |
/// | [ComponentModel.didChangeDependencies] | After init, when inherited data changes | React to inherited data |
/// | [ComponentModel.didUpdateComponent] | When component configuration changes | React to config changes |
/// | [ComponentModel.activate] | When reinserted after deactivate | Resume operations |
/// | [ComponentModel.deactivate] | When temporarily removed from tree | Pause operations |
/// | [ComponentModel.dispose] | Once, when permanently removed | Clean up resources |
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
/// Handle errors in ComponentModel:
///
/// ```dart
/// class DataComponentModel extends ComponentModel<DataComponent, DataModel> {
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
///   stream: cm.countStream,
///   initialData: cm.count,
///   builder: (context, snapshot) {
///     return Component.text('Count: ${snapshot.data}');
///   },
/// )
/// ```
///
/// ### ChangeNotifier
///
/// ```dart
/// class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel>
///     with ChangeNotifier {
///   void increment() {
///     model.increment();
///     notifyListeners();
///   }
/// }
///
/// // In component
/// ListenableBuilder(
///   listenable: cm,
///   builder: (context) {
///     return Component.text('Count: ${cm.count}');
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
/// | `WidgetModel` | `ComponentModel` |
/// | `IWidgetModel` | `IComponentModel` |
/// | `ElementaryModel` | `ElementaryModel` |
/// | `WidgetModelFactory` | `ComponentModelFactory` |
/// | `BuildContext` | `BuildContext` |
///
/// ### Code migration example
///
/// **Flutter:**
/// ```dart
/// class CounterWidget extends ElementaryWidget<CounterComponentModel> {
///   @override
///   Widget build(CounterComponentModel cm) {
///     return Scaffold(
///       body: Text('Count: ${cm.count}'),
///     );
///   }
/// }
/// ```
///
/// **Jaspr:**
/// ```dart
/// class CounterComponent extends ElementaryComponent<CounterComponentModel> {
///   @override
///   Component build(CounterComponentModel cm) {
///     return Component.element(
///       tag: 'div',
///       children: [Component.text('Count: ${cm.count}')],
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
///    controllers in [ComponentModel.dispose]
/// 4. **Use isMounted** — Check [ComponentModel.isMounted] before updating state
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
/// - [ComponentModel] — Base class for presentation logic
/// - [ElementaryModel] — Base class for business logic
/// - [IComponentModel] — Base marker interface for all ComponentModels
/// - [ComponentModelFactory] — Factory function type for creating ComponentModels
/// - [ErrorHandler] — Interface for centralized error handling
/// - [ElementaryElement] — Element that manages ComponentModel lifecycle (internal)
///
/// ## License
///
/// This package is licensed under the MIT License. See the LICENSE file for
/// details.
library;

export 'src/jaspr_elementary_base.dart';
