import 'package:jaspr/jaspr.dart';
import 'package:jaspr_elementary/jaspr_elementary.dart';

import 'counter.dart';
import 'counter_model.dart';

/// ComponentModel для счётчика.
///
/// Связывает бизнес-логику (CounterModel) с UI (CounterComponent).
/// Управляет состоянием представления и пользовательскими взаимодействиями.
class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel> {
  /// Флаги для демонстрации жизненного цикла.
  bool _isInitialized = false;
  int _initCount = 0;
  int _updateCount = 0;
  int _disposeCount = 0;

  CounterComponentModel(super.model);

  int get count => model.count;

  Stream<int> get countStream => model.countStream;

  void increment() {
    print('[CounterComponentModel] increment() called');
    model.increment();
  }

  void decrement() {
    print('[CounterComponentModel] decrement() called');
    model.decrement();
  }

  void reset() {
    print('[CounterComponentModel] reset() called');
    model.reset();
  }

  void triggerError() {
    print('[CounterComponentModel] triggerError() called');
    model.doRiskyOperation();
  }

  @override
  void initComponentModel() {
    super.initComponentModel();
    _isInitialized = true;
    _initCount++;
    print('[CounterComponentModel] initComponentModel() called (total: $_initCount)');
  }

  @override
  void didUpdateComponent(CounterComponent oldComponent) {
    super.didUpdateComponent(oldComponent);
    _updateCount++;
    print('[CounterComponentModel] didUpdateComponent() called (total: $_updateCount)');
    print('  - oldComponent.id: ${oldComponent.id}');
    print('  - newComponent.id: ${component.id}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('[CounterComponentModel] didChangeDependencies() called');
  }

  @override
  void activate() {
    super.activate();
    print('[CounterComponentModel] activate() called');
  }

  @override
  void deactivate() {
    super.deactivate();
    print('[CounterComponentModel] deactivate() called');
  }

  @override
  void dispose() {
    _disposeCount++;
    print('[CounterComponentModel] dispose() called (total: $_disposeCount)');
    super.dispose();
  }

  @override
  void onErrorHandle(Object error) {
    super.onErrorHandle(error);
    print('[CounterComponentModel] onErrorHandle() called: $error');
    // Здесь можно показать уведомление пользователю
  }

  /// Статистика жизненного цикла для демонстрации.
  String get lifecycleStats {
    return 'Init: $_initCount | Update: $_updateCount | Dispose: $_disposeCount';
  }

  bool get isInitialized => _isInitialized;
}

/// Фабрика для создания CounterComponentModel.
///
/// Может быть заменена для тестирования или предоставления
/// альтернативной реализации ComponentModel.
CounterComponentModel counterComponentModelFactory(BuildContext context) {
  print('[Factory] Creating CounterComponentModel');
  return CounterComponentModel(CounterModel());
}
