import 'package:meta/meta.dart';

import 'error_handler.dart';

/// A simple implementation of [ErrorHandler] that prints errors to the console.
///
/// This handler is used by default when no custom error handler is provided
/// to [ElementaryModel]. It outputs error messages and optional stack traces
/// to the standard output (console).
///
/// ## Usage
///
/// This class is primarily intended for development and debugging purposes.
/// In production environments, you should consider implementing a custom
/// [ErrorHandler] that:
///
/// - Logs errors to a remote monitoring service (e.g., Sentry, Crashlytics)
/// - Filters sensitive information from error messages
/// - Implements different behavior based on error type or severity
/// - Stores errors locally for later analysis
///
/// ## Example
///
/// ### Default behavior (development)
/// ```dart
/// class CounterModel extends ElementaryModel {
///   // Uses default ConsoleErrorHandler internally
///   void doRiskyOperation() {
///     try {
///       // Something might go wrong
///     } catch (error, stackTrace) {
///       handleError(error, stackTrace: stackTrace);
///       // Output: "Elementary Error: Exception: Something went wrong"
///       //         "Stack trace: ..."
///     }
///   }
/// }
/// ```
///
/// ### Custom error handler (production)
/// ```dart
/// class ProductionErrorHandler implements ErrorHandler {
///   @override
///   void handleError(Object error, {StackTrace? stackTrace}) {
///     // Send to monitoring service
///     Sentry.captureException(error, stackTrace: stackTrace);
///
///     // Log to file for later analysis
///     Logger.logError(error, stackTrace);
///
///     // Don't print to console in production
///   }
/// }
///
/// class CounterModel extends ElementaryModel {
///   CounterModel() : super(errorHandler: ProductionErrorHandler());
/// }
/// ```
///
/// ## Output format
///
/// Errors are printed in the following format:
/// ```
/// Elementary Error: <error message>
/// Stack trace: <stack trace>
/// ```
///
/// If no stack trace is provided, only the error message is printed.
///
/// ## Important notes
///
/// - This class is marked as [@internal] and is not part of the public API
/// - It may be changed or removed without notice in future versions
/// - For production use, always implement a custom [ErrorHandler]
/// - Console output may be disabled or filtered in some environments
///
/// See also:
///
///  * [ErrorHandler], for the interface that this class implements
///  * [ElementaryModel], for the class that uses this error handler
///  * [ViewModel.onErrorHandle], for how errors are propagated to the UI
@internal
class ConsoleErrorHandler implements ErrorHandler {
  /// Creates an instance of [ConsoleErrorHandler].
  ///
  /// This constructor has no parameters and does not require any initialization.
  const ConsoleErrorHandler();

  /// Handles an error by printing it to the console.
  ///
  /// This method outputs the error message and optional stack trace to the
  /// standard output using [print()]. The output is prefixed with
  /// "Elementary Error: " for easy identification.
  ///
  /// ## Parameters
  /// - [error] — the error object to be printed. Can be any Object, but
  ///   typically an Exception or Error instance.
  /// - [stackTrace] — optional stack trace associated with the error. If provided,
  ///   it will be printed on a separate line after the error message.
  ///
  /// ## Output example
  /// ```
  /// Elementary Error: Exception: Network request failed
  /// Stack trace: #0      HttpClient._openUrl (dart:_http/...)
  ///              #1      HttpClient.getUrl (dart:_http/...)
  ///              #2      ApiService.fetchData (package:my_app/api.dart:42)
  /// ```
  ///
  /// ## Important
  /// - This method does not throw or rethrow the error
  /// - It does not prevent the error from propagating further
  /// - It is purely for logging/debugging purposes
  /// - In production, consider using a more sophisticated error handler
  @override
  void handleError(Object error, {StackTrace? stackTrace}) {
    // Print error message with prefix for easy identification
    print('Elementary Error: $error');

    // Print stack trace if available
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
}
