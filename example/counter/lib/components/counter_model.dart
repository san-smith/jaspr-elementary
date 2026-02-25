import 'dart:async';

import 'package:jaspr_elementary/jaspr_elementary.dart';

/// Модель бизнес-логики для счётчика.
///
/// Содержит чистую бизнес-логику без зависимостей от UI.
/// Может быть протестирована независимо от Jaspr.
class CounterModel extends ElementaryModel {
  int _count = 0;

  /// Текущее значение счётчика.
  int get count => _count;

  /// Стрим для уведомления UI об изменениях.
  /// Используем StreamController для реактивности.
  final _countController = StreamController<int>.broadcast();
  Stream<int> get countStream => _countController.stream;

  @override
  void init() {
    super.init();
    // Логирование для демонстрации жизненного цикла
    print('[CounterModel] init() called');
  }

  /// Увеличивает счётчик на 1.
  void increment() {
    _count++;
    _countController.add(_count);
    print('[CounterModel] increment() called, count = $_count');
  }

  /// Уменьшает счётчик на 1.
  void decrement() {
    _count--;
    _countController.add(_count);
    print('[CounterModel] decrement() called, count = $_count');
  }

  /// Сбрасывает счётчик в 0.
  void reset() {
    _count = 0;
    _countController.add(_count);
    print('[CounterModel] reset() called');
  }

  /// Демонстрация обработки ошибок.
  void doRiskyOperation() {
    try {
      // Симуляция ошибки
      throw Exception('Something went wrong in business logic!');
    } catch (error, stackTrace) {
      handleError(error, stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _countController.close();
    print('[CounterModel] dispose() called');
    super.dispose();
  }
}
