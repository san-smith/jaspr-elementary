import 'package:jaspr/jaspr.dart';
import 'package:meta/meta.dart';

import '../component/elementary_component.dart';
import '../model/elementary_model.dart';

/// Базовый класс для ViewModel в архитектуре MVVM.
abstract class ViewModel<
  C extends ElementaryComponent,
  M extends ElementaryModel
> {
  final M _model;

  /// Контекст построения компонента.
  ///
  /// Устанавливается из [ElementaryElement] при инициализации.
  @internal
  BuildContext? element;

  /// Компонент, который использует эту ViewModel.
  ///
  /// Устанавливается из [ElementaryElement] при инициализации.
  @internal
  C? componentInstance;

  /// Экземпляр модели бизнес-логики.
  @protected
  @visibleForTesting
  M get model => _model;

  /// Компонент, который использует эту ViewModel.
  @protected
  @visibleForTesting
  C get component => componentInstance!;

  /// Контекст построения компонента.
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

  /// Индикатор того, что ViewModel активна в дереве компонентов.
  @protected
  @visibleForTesting
  bool get isMounted => element != null;

  ViewModel(this._model);

  /// Инициализирует ViewModel.
  @internal
  @mustCallSuper
  void initViewModel() {
    _model.setupVmHandler(onErrorHandle);
    _model.init();
  }

  /// Вызывается при обновлении конфигурации компонента.
  @internal
  @mustCallSuper
  void didUpdateComponent(C oldComponent) {}

  /// Вызывается при изменении зависимостей компонента.
  @internal
  @mustCallSuper
  void didChangeDependencies() {}

  /// Обрабатывает ошибки от [ElementaryModel].
  @internal
  @mustCallSuper
  void onErrorHandle(Object error) {}

  /// Вызывается когда ViewModel удаляется из дерева компонентов.
  @internal
  @mustCallSuper
  void deactivate() {}

  /// Вызывается когда ViewModel возвращается в дерево после [deactivate()].
  @internal
  @mustCallSuper
  void activate() {}

  /// Освобождает ресурсы ViewModel.
  @internal
  @mustCallSuper
  void dispose() {
    _model.dispose();
  }

  /// Устанавливает тестовый компонент.
  @visibleForTesting
  void setupTestComponent(C? testComponent) {
    componentInstance = testComponent;
  }

  /// Устанавливает тестовый контекст.
  @visibleForTesting
  void setupTestElement(BuildContext? testElement) {
    element = testElement;
  }

  /// Вызывает обработчик ошибок для тестирования.
  @visibleForTesting
  void handleTestError(Object error) {
    onErrorHandle(error);
  }
}
