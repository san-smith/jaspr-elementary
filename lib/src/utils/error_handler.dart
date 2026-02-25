/// An interface for handling errors in [ElementaryModel].
///
/// [ErrorHandler] allows centralized handling of business logic errors,
/// such as logging, sending to monitoring services, or displaying user-facing
/// error messages. This interface is implemented by concrete error handlers
/// that define how errors should be processed in a specific application.
///
/// ## Purpose
///
/// In MVVM architecture, business logic errors should be separated from UI
/// concerns. [ErrorHandler] provides a clean abstraction layer that allows:
///
/// - **Centralized error handling** — All errors flow through a single point
/// - **Environment-specific behavior** — Different handlers for dev/prod
/// - **Testability** — Easy to mock error handling in unit tests
/// - **Flexibility** — Swap handlers without changing business logic
///
/// ## Implementation guidelines
///
/// When implementing [ErrorHandler], consider the following:
///
/// 1. **Do not rethrow errors** — This handler is for side effects only (logging,
///    analytics, etc.). The error has already been caught in the business logic.
///
/// 2. **Handle all error types** — The [error] parameter can be any Object, not
///    just Exception or Error. Be prepared to handle strings, custom error
///    objects, etc.
///
/// 3. **Use stackTrace** — When available, always include the stack trace in
///    logs or error reports for easier debugging.
///
/// 4. **Avoid UI operations** — This handler should not directly manipulate UI
///    elements. Use [ViewModel.onErrorHandle] for UI-related error reactions.
///
/// ## Examples
///
/// ### Simple console logger (development)
/// ```dart
/// class ConsoleErrorHandler implements ErrorHandler {
///   @override
///   void handleError(Object error, {StackTrace? stackTrace}) {
///     print('Error: $error');
///     if (stackTrace != null) {
///       print('Stack trace: $stackTrace');
///     }
///   }
/// }
/// ```
///
/// ### Production error handler with Sentry
/// ```dart
/// class ProductionErrorHandler implements ErrorHandler {
///   @override
///   void handleError(Object error, {StackTrace? stackTrace}) {
///     // Send to Sentry for monitoring
///     Sentry.captureException(error, stackTrace: stackTrace);
///
///     // Log to file for offline analysis
///     Logger.logError(error, stackTrace: stackTrace);
///
///     // Do not print to console in production
///   }
/// }
/// ```
///
/// ### Error handler with filtering
/// ```dart
/// class FilteringErrorHandler implements ErrorHandler {
///   @override
///   void handleError(Object error, {StackTrace? stackTrace}) {
///     // Ignore network errors in certain situations
///     if (error is NetworkException && error.isExpected) {
///       return;
///     }
///
///     // Handle all other errors
///     reportError(error, stackTrace: stackTrace);
///   }
/// }
/// ```
///
/// ### Usage in ElementaryModel
/// ```dart
/// class CounterModel extends ElementaryModel {
///   CounterModel() : super(errorHandler: MyErrorHandler());
///
///   void doRiskyOperation() {
///     try {
///       // Something might go wrong
///     } catch (error, stackTrace) {
///       handleError(error, stackTrace: stackTrace);
///     }
///   }
/// }
/// ```
///
/// ## Error flow
///
/// ```
/// Business Logic (ElementaryModel)
///         ↓
///   handleError()
///         ↓
///   ┌─────────────────┐
///   │ ErrorHandler    │ → Logging, Analytics, Monitoring
///   │.handleError()   │
///   └─────────────────┘
///         ↓
///   ViewModel.onErrorHandle() → UI reactions (snackbar, dialog, etc.)
/// ```
///
/// ## Best practices
///
/// 1. **Separate concerns** — Keep error handling logic separate from business
///    logic. Use this interface to define the boundary.
///
/// 2. **Consider error severity** — Implement different handling for different
///    error types (warnings vs. critical errors).
///
/// 3. **Respect privacy** — Do not log sensitive information (user data, tokens,
///    etc.) in error messages.
///
/// 4. **Test your handler** — Write unit tests to ensure errors are handled
///    correctly in all scenarios.
///
/// 5. **Document behavior** — Clearly document what your handler does with
///    errors (logs, sends, ignores, etc.).
///
/// See also:
///
///  * [ElementaryModel], for the class that uses this error handler
///  * [ViewModel.onErrorHandle], for UI-layer error handling
///  * [ConsoleErrorHandler], for a simple development error handler
abstract class ErrorHandler {
  /// Handles an error with an optional stack trace.
  ///
  /// This method is called when an error occurs in the business logic layer.
  /// Implementations should process the error appropriately (log, send to
  /// monitoring service, store locally, etc.) without rethrowing it.
  ///
  /// ## Parameters
  /// - [error] — the error object. Can be any Object (Exception, Error, String,
  ///   or custom error type). Do not assume a specific type.
  /// - [stackTrace] — optional stack trace associated with the error. May be
  ///   null if the error was not caught with a stack trace or if the error
  ///   source does not provide one.
  ///
  /// ## Implementation requirements
  ///
  /// 1. **Must not throw** — This method should never throw an exception.
  ///    If an error occurs while handling another error, catch and log it
  ///    internally to prevent cascading failures.
  ///
  /// 2. **Must be synchronous** — This method should complete synchronously.
  ///    If asynchronous operations are needed (e.g., sending to a server),
  ///    fire them without awaiting.
  ///
  /// 3. **Must handle null stackTrace** — The stack trace is optional. Your
  ///    implementation should work correctly even when it is null.
  ///
  /// ## Example implementation
  /// ```dart
  /// class MyErrorHandler implements ErrorHandler {
  ///   @override
  ///   void handleError(Object error, {StackTrace? stackTrace}) {
  ///     try {
  ///       // Log error
  ///       logger.error('Application error', error, stackTrace);
  ///
  ///       // Send to monitoring service (fire and forget)
  ///       monitoringService.sendError(error, stackTrace: stackTrace);
  ///     } catch (handlingError) {
  ///       // Silently handle errors in error handler
  ///       print('Failed to handle error: $handlingError');
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// ## Common use cases
  ///
  /// - **Development** — Print to console for debugging
  /// - **Production** — Send to crash reporting service (Sentry, Crashlytics)
  /// - **Testing** — Collect errors for assertions
  /// - **Analytics** — Track error frequency and patterns
  void handleError(Object error, {StackTrace? stackTrace});
}
