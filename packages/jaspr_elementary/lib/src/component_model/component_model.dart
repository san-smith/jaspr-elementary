import 'package:jaspr/jaspr.dart';
import 'package:meta/meta.dart';

import '../component/elementary_component.dart';
import '../model/elementary_model.dart';
import 'i_component_model.dart';

/// A base class for ViewModel in MVVM architecture.
///
/// [ComponentModel] connects business logic ([ElementaryModel]) with UI ([ElementaryComponent]).
/// It manages presentation state and handles user interactions.
///
/// ## Type parameters
/// - [C] — the type of component that uses this ComponentModel
/// - [M] — the type of business logic model
///
/// ## Lifecycle
/// ```
/// create → initComponentModel() → didChangeDependencies() → build()
///                              ↓
///                    didUpdateComponent() (on component update)
///                              ↓
///                         dispose() (on destruction)
/// ```
///
/// ## Usage examples
///
/// ### Without interface (simpler)
/// ```dart
/// class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel> {
///   CounterComponentModel(CounterModel model) : super(model);
///
///   int get count => model.count;
///   void increment() => model.increment();
/// }
///
/// class CounterComponent extends ElementaryComponent<CounterComponentModel> {
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
///
/// class CounterComponent extends ElementaryComponent<ICounterComponentModel> {
///   @override
///   Component build(ICounterComponentModel cm) {
///     // ...
///   }
/// }
/// ```
///
/// ## Access to context
/// Use the [context] property to access [BuildContext].
/// This is useful for obtaining data from [InheritedComponent] or navigation.
///
/// ## Important
/// - ComponentModel is created once and lives as long as the component is in the tree
/// - Do not store references to components in ComponentModel
/// - Release resources in [dispose()]
/// - Use [isMounted] to prevent memory leaks in async operations
///
/// ## Async operations example
/// ```dart
/// class DataComponentModel extends ComponentModel<DataComponent, DataModel> {
///   DataComponentModel(DataModel model) : super(model);
///
///   Future<void> loadData() async {
///     final data = await api.fetchData();
///     if (isMounted) {
///       // Safe to update state
///       model.updateData(data);
///     }
///   }
/// }
/// ```
///
/// ## Migration from Flutter Elementary
///
/// If you are familiar with the Flutter `elementary` package:
///
/// | Flutter Elementary | Jaspr Elementary |
/// |-------------------|------------------|
/// | `WidgetModel` | `ComponentModel` |
/// | `ElementaryWidget` | `ElementaryComponent` |
/// | `ElementaryModel` | `ElementaryModel` |
/// | `IWidgetModel` | `IComponentModel` |
///
/// See also:
///
///  * [ElementaryComponent], for the component that uses this ComponentModel
///  * [ElementaryModel], for the business logic layer
///  * [IComponentModel], for the base marker interface
abstract class ComponentModel<
  C extends ElementaryComponent,
  M extends ElementaryModel
>
    implements IComponentModel {
  /// The business logic model instance.
  ///
  /// This field is final and is set during ComponentModel construction.
  final M _model;

  /// The build context of the component.
  ///
  /// This field is set by [ElementaryElement] during initialization.
  /// It provides access to the element tree and inherited data.
  ///
  /// ## Important
  /// This field is internal and should not be accessed directly outside of
  /// the jaspr_elementary package. Use [context] getter instead.
  @internal
  BuildContext? element;

  /// The component that uses this ComponentModel.
  ///
  /// This field is set by [ElementaryElement] during initialization.
  /// It contains the current configuration of the component.
  ///
  /// ## Important
  /// This field is internal and should not be accessed directly outside of
  /// the jaspr_elementary package. Use [component] getter instead.
  @internal
  C? componentInstance;

  /// The business logic model instance.
  ///
  /// Use this to access data and business logic methods.
  ///
  /// ## Example
  /// ```dart
  /// class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel> {
  ///   CounterComponentModel(CounterModel model) : super(model);
  ///
  ///   int get count => model.count;
  ///
  ///   void increment() {
  ///     model.increment();
  ///   }
  /// }
  /// ```
  @protected
  @visibleForTesting
  M get model => _model;

  /// The component that uses this ComponentModel.
  ///
  /// Contains the current configuration of the component.
  /// May be updated during the lifecycle.
  ///
  /// ## Important
  /// This getter will throw if called before the ComponentModel is initialized
  /// or after it is disposed.
  @protected
  @visibleForTesting
  C get component => componentInstance!;

  /// The build context of the component.
  ///
  /// Use this to access inherited data ([InheritedComponent])
  /// or for other operations requiring [BuildContext].
  ///
  /// ## Example
  /// ```dart
  /// class MyComponentModel extends ComponentModel<MyComponent, MyModel> {
  ///   void loadData() {
  ///     final config = Config.of(context);
  ///     // Use config to load data
  ///   }
  /// }
  /// ```
  ///
  /// ## Important
  /// Throws [StateError] if called after [dispose()].
  ///
  /// ## Lifecycle
  /// - Available after [initComponentModel()] is called
  /// - Available until [dispose()] is called
  /// - Not available in constructor or after dispose
  @protected
  @visibleForTesting
  BuildContext get context {
    assert(() {
      if (element == null) {
        throw StateError(
          'BuildContext is not available. The ComponentModel has been disposed.',
        );
      }
      return true;
    }());
    return element!;
  }

  /// Indicates whether the ComponentModel is currently mounted in the component tree.
  ///
  /// Use this to prevent memory leaks in asynchronous operations.
  ///
  /// ## Example
  /// ```dart
  /// class DataComponentModel extends ComponentModel<DataComponent, DataModel> {
  ///   Future<void> loadData() async {
  ///     final data = await api.fetchData();
  ///     if (isMounted) {
  ///       // Safe to update state
  ///       model.updateData(data);
  ///     } else {
  ///       // ComponentModel was disposed, ignore the result
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// ## Returns
  /// - `true` — the ComponentModel is currently mounted and can safely update state
  /// - `false` — the ComponentModel has been disposed and should not be used
  @protected
  @visibleForTesting
  bool get isMounted => element != null;

  /// Creates an instance of ComponentModel with the specified model.
  ///
  /// ## Parameters
  /// - [model] — instance of [ElementaryModel] for business logic
  ///
  /// ## Example
  /// ```dart
  /// class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel> {
  ///   CounterComponentModel(CounterModel model) : super(model);
  /// }
  /// ```
  ComponentModel(this._model);

  /// Initializes the ComponentModel.
  ///
  /// Called once before the first render of the component.
  /// Use this for initial state setup and subscriptions.
  ///
  /// ## Lifecycle
  /// This method is called in the following order:
  /// ```
  /// 1. ComponentModel created via factory
  /// 2. initComponentModel() called
  /// 3. model.init() called
  /// 4. didChangeDependencies() called
  /// 5. build() called
  /// ```
  ///
  /// ## Example
  /// ```dart
  /// class DataComponentModel extends ComponentModel<DataComponent, DataModel> {
  ///   @override
  ///   void initComponentModel() {
  ///     super.initComponentModel();
  ///     // Initialize state
  ///     _isLoading = true;
  ///     // Load initial data
  ///     loadData();
  ///   }
  /// }
  /// ```
  ///
  /// ## Important
  /// Always call `super.initComponentModel()` in subclasses to ensure
  /// proper initialization of the model and error handling.
  @mustCallSuper
  void initComponentModel() {
    _model.setupCmHandler(onErrorHandle);
    _model.init();
  }

  /// Called when the component configuration is updated.
  ///
  /// This method signals that the parent component has recreated
  /// this component with new parameters. The ComponentModel is NOT recreated.
  ///
  /// ## Parameters
  /// - [oldComponent] — the previous version of the component
  ///
  /// ## Example
  /// ```dart
  /// class UserComponentModel extends ComponentModel<UserComponent, UserModel> {
  ///   @override
  ///   void didUpdateComponent(UserComponent oldComponent) {
  ///     super.didUpdateComponent(oldComponent);
  ///     if (oldComponent.userId != component.userId) {
  ///       // User ID changed, load new data
  ///       loadUser(component.userId);
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// ## Lifecycle
  /// This method is called:
  /// - When the parent rebuilds and creates a new component instance
  /// - Before the [build()] method is called with the new configuration
  ///
  /// ## Important
  /// - The ComponentModel instance is preserved across updates
  /// - Use this method to react to configuration changes
  /// - Do not recreate state here, update existing state instead
  @mustCallSuper
  void didUpdateComponent(C oldComponent) {}

  /// Called when the component's dependencies change.
  ///
  /// Dependencies are data obtained through [BuildContext] from
  /// [InheritedComponent]. This method is called immediately after [initComponentModel()].
  ///
  /// ## Example
  /// ```dart
  /// class ThemeComponentModel extends ComponentModel<ThemeComponent, ThemeModel> {
  ///   @override
  ///   void didChangeDependencies() {
  ///     super.didChangeDependencies();
  ///     final theme = Theme.of(context);
  ///     // Update state based on theme
  ///   }
  /// }
  /// ```
  ///
  /// ## Lifecycle
  /// This method is called:
  /// - Immediately after [initComponentModel()] during first build
  /// - When an [InheritedComponent] notifies its dependents of changes
  ///
  /// ## Important
  /// - Use this to react to inherited data changes
  /// - Do not perform heavy operations here
  /// - Call `super.didChangeDependencies()` in subclasses
  @mustCallSuper
  void didChangeDependencies() {}

  /// Handles errors from [ElementaryModel].
  ///
  /// This method is called when [ElementaryModel.handleError()] is invoked.
  /// Use this to show notifications to the user or log errors.
  ///
  /// ## Parameters
  /// - [error] — the error object
  ///
  /// ## Example
  /// ```dart
  /// class DataComponentModel extends ComponentModel<DataComponent, DataModel> {
  ///   @override
  ///   void onErrorHandle(Object error) {
  ///     super.onErrorHandle(error);
  ///     // Show error to user
  ///     showErrorSnackbar('Failed to load data: $error');
  ///     // Log error
  ///     logger.error('Data load failed', error);
  ///   }
  /// }
  /// ```
  ///
  /// ## Error flow
  /// ```
  /// Business Logic → model.handleError()
  ///              → ComponentModel.onErrorHandle()
  ///              → UI reaction (snackbar, dialog, etc.)
  /// ```
  ///
  /// ## Important
  /// - This method is called on the UI thread
  /// - Keep error handling logic lightweight
  /// - Do not throw exceptions from this method
  @mustCallSuper
  void onErrorHandle(Object error) {}

  /// Called when the ComponentModel is removed from the component tree.
  ///
  /// The ComponentModel may be temporarily removed and then returned (for example,
  /// when rebuilding the tree with GlobalKey). In this case, [activate()] will
  /// be called later.
  ///
  /// ## Lifecycle
  /// This method is part of the deactivation process:
  /// ```
  /// deactivate() → (optionally) activate() → or → unmount() → dispose()
  /// ```
  ///
  /// ## Example
  /// ```dart
  /// class StreamComponentModel extends ComponentModel<StreamComponent, StreamModel> {
  ///   StreamSubscription? _subscription;
  ///
  ///   @override
  ///   void deactivate() {
  ///     // Pause subscriptions when temporarily removed
  ///     _subscription?.pause();
  ///     super.deactivate();
  ///   }
  ///
  ///   @override
  ///   void activate() {
  ///     // Resume subscriptions when returned to tree
  ///     _subscription?.resume();
  ///     super.activate();
  ///   }
  /// }
  /// ```
  ///
  /// ## Important
  /// Always call `super.deactivate()` in subclasses.
  @mustCallSuper
  void deactivate() {}

  /// Called when the ComponentModel is reinserted into the tree after [deactivate()].
  ///
  /// Use this to resume subscriptions or operations that were
  /// paused during deactivation.
  ///
  /// ## Lifecycle
  /// This method is NOT called the first time a ComponentModel becomes active.
  /// Instead, [initComponentModel()] is called in that situation.
  ///
  /// ## Example
  /// ```dart
  /// class StreamComponentModel extends ComponentModel<StreamComponent, StreamModel> {
  ///   @override
  ///   void activate() {
  ///     super.activate();
  ///     // Resume operations
  ///     _resumeDataStream();
  ///   }
  /// }
  /// ```
  ///
  /// ## Important
  /// Always call `super.activate()` in subclasses.
  @mustCallSuper
  void activate() {}

  /// Releases resources held by the ComponentModel.
  ///
  /// Called once when the ComponentModel is permanently removed from the tree.
  /// After this method is called, the ComponentModel should not be used.
  ///
  /// ## Cleanup checklist
  /// - Cancel all stream subscriptions
  /// - Dispose of all controllers
  /// - Remove all listeners
  /// - Cancel all pending async operations
  ///
  /// ## Example
  /// ```dart
  /// class DataComponentModel extends ComponentModel<DataComponent, DataModel> {
  ///   StreamSubscription? _subscription;
  ///   Timer? _timer;
  ///
  ///   @override
  ///   void dispose() {
  ///     _subscription?.cancel();
  ///     _timer?.cancel();
  ///     super.dispose();
  ///   }
  /// }
  /// ```
  ///
  /// ## Lifecycle
  /// This method is called in the following order:
  /// ```
  /// unmount() → ComponentModel.dispose() → model.dispose()
  /// ```
  ///
  /// ## Important
  /// - Always call `super.dispose()` in subclasses
  /// - After this method, the ComponentModel is in an undefined state
  /// - Do not call any methods on the ComponentModel after dispose
  @mustCallSuper
  void dispose() {
    _model.dispose();
  }

  /// Sets a test component.
  ///
  /// Use only for unit testing.
  ///
  /// ## Parameters
  /// - [testComponent] — mock component for testing
  ///
  /// ## Example
  /// ```dart
  /// test('ComponentModel uses component', () {
  ///   final componentModel = TestComponentModel(TestModel());
  ///   final mockComponent = MockTestComponent();
  ///   ComponentModel.setupTestComponent(mockComponent);
  ///
  ///   // Test ComponentModel behavior with mock component
  ///   expect(componentModel.component, equals(mockComponent));
  /// });
  /// ```
  @visibleForTesting
  void setupTestComponent(C? testComponent) {
    componentInstance = testComponent;
  }

  /// Sets a test build context.
  ///
  /// Use only for unit testing.
  ///
  /// ## Parameters
  /// - [testElement] — mock build context for testing
  ///
  /// ## Example
  /// ```dart
  /// test('ComponentModel uses context', () {
  ///   final componentModel = TestComponentModel(TestModel());
  ///   final mockContext = MockBuildContext();
  ///   componentModel.setupTestElement(mockContext);
  ///
  ///   // Test ComponentModel behavior with mock context
  ///   expect(ComponentModel.context, equals(mockContext));
  /// });
  /// ```
  @visibleForTesting
  void setupTestElement(BuildContext? testElement) {
    element = testElement;
  }

  /// Calls the error handler for testing.
  ///
  /// Use only for unit testing.
  ///
  /// ## Parameters
  /// - [error] — the error object to test with
  ///
  /// ## Example
  /// ```dart
  /// test('ComponentModel handles errors', () {
  ///   final componentModel = TestComponentModel(TestModel());
  ///   final testError = Exception('Test error');
  ///
  ///   componentModel.handleTestError(testError);
  ///
  ///   expect(componentModel.errorHandled, isTrue);
  ///   expect(Model.lastError, equals(testError));
  /// });
  /// ```
  @visibleForTesting
  void handleTestError(Object error) {
    onErrorHandle(error);
  }
}
