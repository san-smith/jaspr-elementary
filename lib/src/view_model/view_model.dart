import 'package:jaspr/jaspr.dart';
import 'package:meta/meta.dart';

import '../component/elementary_component.dart';
import '../model/elementary_model.dart';
import 'i_view_model.dart';

/// A base class for ViewModel in MVVM architecture.
///
/// [ViewModel] connects business logic ([ElementaryModel]) with UI ([ElementaryComponent]).
/// It manages presentation state and handles user interactions.
///
/// ## Type parameters
/// - [C] — the type of component that uses this ViewModel
/// - [M] — the type of business logic model
///
/// ## Lifecycle
/// ```
/// create → initViewModel() → didChangeDependencies() → build()
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
/// class CounterViewModel extends ViewModel<CounterComponent, CounterModel> {
///   CounterViewModel(CounterModel model) : super(model);
///
///   int get count => model.count;
///   void increment() => model.increment();
/// }
///
/// class CounterComponent extends ElementaryComponent<CounterViewModel> {
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
///
/// class CounterComponent extends ElementaryComponent<ICounterViewModel> {
///   @override
///   Component build(ICounterViewModel vm) {
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
/// - ViewModel is created once and lives as long as the component is in the tree
/// - Do not store references to widgets in ViewModel
/// - Release resources in [dispose()]
/// - Use [isMounted] to prevent memory leaks in async operations
///
/// ## Async operations example
/// ```dart
/// class DataViewModel extends ViewModel<DataComponent, DataModel> {
///   DataViewModel(DataModel model) : super(model);
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
/// | `WidgetModel` | `ViewModel` |
/// | `ElementaryWidget` | `ElementaryComponent` |
/// | `ElementaryModel` | `ElementaryModel` |
/// | `IWidgetModel` | `IViewModel` |
///
/// See also:
///
///  * [ElementaryComponent], for the component that uses this ViewModel
///  * [ElementaryModel], for the business logic layer
///  * [IViewModel], for the base marker interface
abstract class ViewModel<
  C extends ElementaryComponent,
  M extends ElementaryModel
>
    implements IViewModel {
  /// The business logic model instance.
  ///
  /// This field is final and is set during ViewModel construction.
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

  /// The component that uses this ViewModel.
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
  /// class CounterViewModel extends ViewModel<CounterComponent, CounterModel> {
  ///   CounterViewModel(CounterModel model) : super(model);
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

  /// The component that uses this ViewModel.
  ///
  /// Contains the current configuration of the component.
  /// May be updated during the lifecycle.
  ///
  /// ## Important
  /// This getter will throw if called before the ViewModel is initialized
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
  /// class MyViewModel extends ViewModel<MyComponent, MyModel> {
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
  /// - Available after [initViewModel()] is called
  /// - Available until [dispose()] is called
  /// - Not available in constructor or after dispose
  @protected
  @visibleForTesting
  BuildContext get context {
    assert(() {
      if (element == null) {
        throw StateError(
          'BuildContext is not available. The ViewModel has been disposed.',
        );
      }
      return true;
    }());
    return element!;
  }

  /// Indicates whether the ViewModel is currently mounted in the component tree.
  ///
  /// Use this to prevent memory leaks in asynchronous operations.
  ///
  /// ## Example
  /// ```dart
  /// class DataViewModel extends ViewModel<DataComponent, DataModel> {
  ///   Future<void> loadData() async {
  ///     final data = await api.fetchData();
  ///     if (isMounted) {
  ///       // Safe to update state
  ///       model.updateData(data);
  ///     } else {
  ///       // ViewModel was disposed, ignore the result
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// ## Returns
  /// - `true` — the ViewModel is currently mounted and can safely update state
  /// - `false` — the ViewModel has been disposed and should not be used
  @protected
  @visibleForTesting
  bool get isMounted => element != null;

  /// Creates an instance of ViewModel with the specified model.
  ///
  /// ## Parameters
  /// - [model] — instance of [ElementaryModel] for business logic
  ///
  /// ## Example
  /// ```dart
  /// class CounterViewModel extends ViewModel<CounterComponent, CounterModel> {
  ///   CounterViewModel(CounterModel model) : super(model);
  /// }
  /// ```
  ViewModel(this._model);

  /// Initializes the ViewModel.
  ///
  /// Called once before the first render of the component.
  /// Use this for initial state setup and subscriptions.
  ///
  /// ## Lifecycle
  /// This method is called in the following order:
  /// ```
  /// 1. ViewModel created via factory
  /// 2. initViewModel() called
  /// 3. model.init() called
  /// 4. didChangeDependencies() called
  /// 5. build() called
  /// ```
  ///
  /// ## Example
  /// ```dart
  /// class DataViewModel extends ViewModel<DataComponent, DataModel> {
  ///   @override
  ///   void initViewModel() {
  ///     super.initViewModel();
  ///     // Initialize state
  ///     _isLoading = true;
  ///     // Load initial data
  ///     loadData();
  ///   }
  /// }
  /// ```
  ///
  /// ## Important
  /// Always call `super.initViewModel()` in subclasses to ensure
  /// proper initialization of the model and error handling.
  @mustCallSuper
  void initViewModel() {
    _model.setupVmHandler(onErrorHandle);
    _model.init();
  }

  /// Called when the component configuration is updated.
  ///
  /// This method signals that the parent component has recreated
  /// this component with new parameters. The ViewModel is NOT recreated.
  ///
  /// ## Parameters
  /// - [oldComponent] — the previous version of the component
  ///
  /// ## Example
  /// ```dart
  /// class UserViewModel extends ViewModel<UserComponent, UserModel> {
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
  /// - The ViewModel instance is preserved across updates
  /// - Use this method to react to configuration changes
  /// - Do not recreate state here, update existing state instead
  @mustCallSuper
  void didUpdateComponent(C oldComponent) {}

  /// Called when the component's dependencies change.
  ///
  /// Dependencies are data obtained through [BuildContext] from
  /// [InheritedComponent]. This method is called immediately after [initViewModel()].
  ///
  /// ## Example
  /// ```dart
  /// class ThemeViewModel extends ViewModel<ThemeComponent, ThemeModel> {
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
  /// - Immediately after [initViewModel()] during first build
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
  /// class DataViewModel extends ViewModel<DataComponent, DataModel> {
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
  ///              → ViewModel.onErrorHandle()
  ///              → UI reaction (snackbar, dialog, etc.)
  /// ```
  ///
  /// ## Important
  /// - This method is called on the UI thread
  /// - Keep error handling logic lightweight
  /// - Do not throw exceptions from this method
  @mustCallSuper
  void onErrorHandle(Object error) {}

  /// Called when the ViewModel is removed from the component tree.
  ///
  /// The ViewModel may be temporarily removed and then returned (for example,
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
  /// class StreamViewModel extends ViewModel<StreamComponent, StreamModel> {
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

  /// Called when the ViewModel is reinserted into the tree after [deactivate()].
  ///
  /// Use this to resume subscriptions or operations that were
  /// paused during deactivation.
  ///
  /// ## Lifecycle
  /// This method is NOT called the first time a ViewModel becomes active.
  /// Instead, [initViewModel()] is called in that situation.
  ///
  /// ## Example
  /// ```dart
  /// class StreamViewModel extends ViewModel<StreamComponent, StreamModel> {
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

  /// Releases resources held by the ViewModel.
  ///
  /// Called once when the ViewModel is permanently removed from the tree.
  /// After this method is called, the ViewModel should not be used.
  ///
  /// ## Cleanup checklist
  /// - Cancel all stream subscriptions
  /// - Dispose of all controllers
  /// - Remove all listeners
  /// - Cancel all pending async operations
  ///
  /// ## Example
  /// ```dart
  /// class DataViewModel extends ViewModel<DataComponent, DataModel> {
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
  /// unmount() → ViewModel.dispose() → model.dispose()
  /// ```
  ///
  /// ## Important
  /// - Always call `super.dispose()` in subclasses
  /// - After this method, the ViewModel is in an undefined state
  /// - Do not call any methods on the ViewModel after dispose
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
  /// test('ViewModel uses component', () {
  ///   final viewModel = TestViewModel(TestModel());
  ///   final mockComponent = MockTestComponent();
  ///   viewModel.setupTestComponent(mockComponent);
  ///
  ///   // Test ViewModel behavior with mock component
  ///   expect(viewModel.component, equals(mockComponent));
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
  /// test('ViewModel uses context', () {
  ///   final viewModel = TestViewModel(TestModel());
  ///   final mockContext = MockBuildContext();
  ///   viewModel.setupTestElement(mockContext);
  ///
  ///   // Test ViewModel behavior with mock context
  ///   expect(viewModel.context, equals(mockContext));
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
  /// test('ViewModel handles errors', () {
  ///   final viewModel = TestViewModel(TestModel());
  ///   final testError = Exception('Test error');
  ///
  ///   viewModel.handleTestError(testError);
  ///
  ///   expect(viewModel.errorHandled, isTrue);
  ///   expect(viewModel.lastError, equals(testError));
  /// });
  /// ```
  @visibleForTesting
  void handleTestError(Object error) {
    onErrorHandle(error);
  }
}
