/// Интерфейс для обработки ошибок в [ElementaryModel].
///
/// Позволяет централизованно обрабатывать ошибки бизнес-логики,
/// например, для логирования или отправки в мониторинг.
///
/// ## Пример использования
/// ```dart
/// class MyErrorHandler implements ErrorHandler {
///   @override
///   void handleError(Object error, {StackTrace? stackTrace}) {
///     // Логирование или отправка в Sentry
///     print('Error: $error');
///   }
/// }
/// ```
abstract class ErrorHandler {
  /// Обрабатывает ошибку с опциональным стеком вызовов.
  void handleError(Object error, {StackTrace? stackTrace});
}
