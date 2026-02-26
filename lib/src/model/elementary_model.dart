import 'package:meta/meta.dart';

import '../utils/error_handler.dart';

/// A base class for the business logic of an application.
///
/// [ElementaryModel] contains pure business logic that is independent of the UI.
/// It is used by [ComponentModel] to obtain data and perform operations.
///
/// ## Lifecycle
/// - [init()] is called once before the first render of the associated component
/// - [dispose()] is called once when the ComponentModel is destroyed
///
/// ## Error handling
/// Use the [handleError()] method to notify the [ComponentModel] about errors.
/// This allows centralized error handling in the presentation layer.
///
/// ## Example usage
/// ```dart
/// class CounterModel extends ElementaryModel {
///   int _count = 0;
///   int get count => _count;
///
///   void increment() {
///     _count++;
///     // Notify ComponentModel about the change (via Stream, ChangeNotifier, etc.)
///   }
///
///   void doRiskyOperation() {
///     try {
///       // Something might go wrong
///     } catch (error, stackTrace) {
///       handleError(error, stackTrace: stackTrace);
///     }
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
/// ## Important principles
///
/// 1. **No UI dependencies** — This class should not import or depend on
///    Jaspr, Flutter, or any UI framework. It should be pure Dart.
///
/// 2. **Testable** — Since it has no UI dependencies, it can be unit tested
///    independently of the framework.
///
/// 3. **Resource management** — Always clean up resources in [dispose()].
///    This includes closing streams, canceling subscriptions, and disposing
///    of any objects that implement a dispose method.
///
/// 4. **Error propagation** — Use [handleError()] to propagate errors to the
///    ComponentModel. This allows the UI to react appropriately (show error messages,
///    log errors, etc.).
///
/// ## Thread safety
/// This class is not thread-safe by default. If you plan to use it with
/// isolates or multiple threads, ensure proper synchronization.
///
/// See also:
///
///  * [ComponentModel], for the presentation logic that uses this model
///  * [ErrorHandler], for centralized error handling
///  * [ElementaryComponent], for the UI component that displays the data
abstract class ElementaryModel {
  /// The error handler for centralized error processing.
  ///
  /// If provided, this handler will be notified of all errors reported via
  /// [handleError()]. This is useful for logging, analytics, or sending
  /// errors to monitoring services.
  final ErrorHandler? _errorHandler;

  /// The error handler callback for the ComponentModel.
  ///
  /// This is set by the [ComponentModel] during initialization via [setupCmHandler()].
  /// When [handleError()] is called, this callback notifies the ComponentModel
  /// so it can react to the error (e.g., show an error message to the user).
  ///
  /// This field is internal and should not be accessed directly outside of
  /// the jaspr_elementary package.
  void Function(Object)? _cmHandler;

  /// Creates an instance of [ElementaryModel] with an optional error handler.
  ///
  /// ## Parameters
  /// - [errorHandler] — optional handler for centralized error processing.
  ///   If not provided, errors will only be notified to the ComponentModel.
  ///
  /// ## Example
  /// ```dart
  /// // Without error handler
  /// final model = CounterModel();
  ///
  /// // With error handler
  /// final model = CounterModel(
  ///   errorHandler: MyErrorHandler(),
  /// );
  /// ```
  ElementaryModel({ErrorHandler? errorHandler}) : _errorHandler = errorHandler;

  /// Reports an error to the [ComponentModel] and [ErrorHandler].
  ///
  /// This method should be called when errors occur in the business logic
  /// so that the [ComponentModel] can react (e.g., show a notification to the user).
  ///
  /// ## Parameters
  /// - [error] — the error object (Exception, String, or any Object)
  /// - [stackTrace] — optional stack trace for debugging
  ///
  /// ## Error flow
  /// ```
  /// Business Logic → handleError() → ComponentModel.onErrorHandle()
  ///                              → ErrorHandler.handleError()
  /// ```
  ///
  /// ## Example usage
  /// ```dart
  /// void fetchData() async {
  ///   try {
  ///     final data = await api.getData();
  ///     // Process data...
  ///   } catch (error, stackTrace) {
  ///     handleError(error, stackTrace: stackTrace);
  ///   }
  /// }
  /// ```
  ///
  /// ## Important
  /// Always call `super.handleError()` when overriding this method in subclasses.
  @protected
  @mustCallSuper
  @visibleForTesting
  void handleError(Object error, {StackTrace? stackTrace}) {
    _errorHandler?.handleError(error, stackTrace: stackTrace);
    _cmHandler?.call(error);
  }

  /// Initializes the model.
  ///
  /// Called once before the first render of the associated component.
  /// Use this method for subscribing to events, loading initial data,
  /// or performing other initialization tasks.
  ///
  /// ## Important
  /// Do not perform heavy operations in this method. For asynchronous
  /// operations, use separate methods called from the ComponentModel.
  ///
  /// ## Example usage
  /// ```dart
  /// @override
  /// void init() {
  ///   super.init();
  ///   // Subscribe to a data stream
  ///   _subscription = dataStream.listen((data) {
  ///     // Process data...
  ///   });
  /// }
  /// ```
  ///
  /// ## Lifecycle position
  /// ```
  /// ComponentModel created → initComponentModel() → model.init() → build()
  /// ```
  void init() {}

  /// Releases resources held by the model.
  ///
  /// Called once when the ComponentModel is destroyed.
  /// Use this method for unsubscribing from streams, closing connections,
  /// and cleaning up any resources that need explicit disposal.
  ///
  /// ## Important
  /// Always call `super.dispose()` in subclasses to ensure proper cleanup.
  ///
  /// ## Example usage
  /// ```dart
  /// @override
  /// void dispose() {
  ///   _subscription?.cancel();
  ///   _controller?.close();
  ///   super.dispose();
  /// }
  /// ```
  ///
  /// ## Lifecycle position
  /// ```
  /// Component unmount → ComponentModel.dispose() → model.dispose()
  /// ```
  void dispose() {}

  /// Sets the error handler callback for the ComponentModel.
  ///
  /// This method is used internally by the [ComponentModel] during initialization
  /// to establish the error handling connection between the model and the
  /// ComponentModel.
  ///
  /// ## Parameters
  /// - [function] — the callback function to be called when an error occurs
  ///
  /// ## Important
  /// This method is internal and should not be called directly by users
  /// of the package. It is exposed for testing purposes only.
  @internal
  void setupCmHandler(void Function(Object)? function) {
    _cmHandler = function;
  }
}
