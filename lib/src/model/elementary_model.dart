import 'package:meta/meta.dart';

import '../utils/error_handler.dart';

/// Базовый класс для бизнес-логики приложения.
abstract class ElementaryModel {
  final ErrorHandler? _errorHandler;

  /// Обработчик ошибок для ViewModel.
  void Function(Object)? _vmHandler;

  ElementaryModel({ErrorHandler? errorHandler}) : _errorHandler = errorHandler;

  /// Сообщает об ошибке в [ViewModel] и [ErrorHandler].
  @protected
  @mustCallSuper
  @visibleForTesting
  void handleError(Object error, {StackTrace? stackTrace}) {
    _errorHandler?.handleError(error, stackTrace: stackTrace);
    _vmHandler?.call(error);
  }

  /// Инициализирует модель.
  void init() {}

  /// Освобождает ресурсы модели.
  void dispose() {}

  /// Устанавливает обработчик ошибок для ViewModel.
  @internal
  void setupVmHandler(void Function(Object)? function) {
    _vmHandler = function;
  }
}
