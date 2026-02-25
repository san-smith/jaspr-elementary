import 'package:meta/meta.dart';

import 'error_handler.dart';

/// Простая реализация [ErrorHandler], которая выводит ошибки в консоль.
///
/// Используется по умолчанию, если не предоставлен свой обработчик.
@internal
class ConsoleErrorHandler implements ErrorHandler {
  @override
  void handleError(Object error, {StackTrace? stackTrace}) {
    // Игнорируем ошибки в production, если нужно
    print('Elementary Error: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
}
