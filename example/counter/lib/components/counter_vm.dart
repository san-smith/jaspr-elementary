import 'package:jaspr/jaspr.dart';
import 'package:jaspr_elementary/jaspr_elementary.dart';

import 'counter.dart';
import 'counter_model.dart';



/// ViewModel для счётчика.
///
/// Связывает бизнес-логику (CounterModel) с UI (CounterComponent).
/// Управляет состоянием представления и пользовательскими взаимодействиями.
class CounterViewModel extends ViewModel<CounterComponent, CounterModel>  {
  /// Флаги для демонстрации жизненного цикла.
  bool _isInitialized = false;
  int _initCount = 0;
  int _updateCount = 0;
  int _disposeCount = 0;

  CounterViewModel(super.model);

  int get count => model.count;

  Stream<int> get countStream => model.countStream;

  void increment() {
    print('[CounterViewModel] increment() called');
    model.increment();
  }

  void decrement() {
    print('[CounterViewModel] decrement() called');
    model.decrement();
  }

  void reset() {
    print('[CounterViewModel] reset() called');
    model.reset();
  }

  void triggerError() {
    print('[CounterViewModel] triggerError() called');
    model.doRiskyOperation();
  }

  @override
  void initViewModel() {
    super.initViewModel();
    _isInitialized = true;
    _initCount++;
    print('[CounterViewModel] initViewModel() called (total: $_initCount)');
  }

  @override
  void didUpdateComponent(CounterComponent oldComponent) {
    super.didUpdateComponent(oldComponent);
    _updateCount++;
    print('[CounterViewModel] didUpdateComponent() called (total: $_updateCount)');
    print('  - oldComponent.id: ${oldComponent.id}');
    print('  - newComponent.id: ${component.id}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('[CounterViewModel] didChangeDependencies() called');
  }

  @override
  void activate() {
    super.activate();
    print('[CounterViewModel] activate() called');
  }

  @override
  void deactivate() {
    super.deactivate();
    print('[CounterViewModel] deactivate() called');
  }

  @override
  void dispose() {
    _disposeCount++;
    print('[CounterViewModel] dispose() called (total: $_disposeCount)');
    super.dispose();
  }

  @override
  void onErrorHandle(Object error) {
    super.onErrorHandle(error);
    print('[CounterViewModel] onErrorHandle() called: $error');
    // Здесь можно показать уведомление пользователю
  }

  /// Статистика жизненного цикла для демонстрации.
  String get lifecycleStats {
    return 'Init: $_initCount | Update: $_updateCount | Dispose: $_disposeCount';
  }

  bool get isInitialized => _isInitialized;
}

/// Фабрика для создания CounterViewModel.
///
/// Может быть заменена для тестирования или предоставления
/// альтернативной реализации ViewModel.
CounterViewModel counterViewModelFactory(BuildContext context) {
  print('[Factory] Creating CounterViewModel');
  return CounterViewModel(CounterModel());
}
