import 'package:jaspr/jaspr.dart';

import '../view_model/view_model.dart';
import 'elementary_component.dart';

/// Element для управления жизненным циклом ViewModel.
///
/// [ElementaryElement] — это кастомный Element, который:
/// - Создает ViewModel один раз при первом построении
/// - Сохраняет ViewModel при пересоздании компонента
/// - Вызывает методы жизненного цикла ViewModel
/// - Уничтожает ViewModel при удалении из дерева
/// - Создаёт и управляет дочерним Element из Component
final class ElementaryElement extends Element {
  @override
  ElementaryComponent get component => super.component as ElementaryComponent;

  late ViewModel _vm;
  bool _isInitialized = false;

  /// Дочерний элемент, созданный из Component returned by build()
  Element? _childElement;

  ElementaryElement(ElementaryComponent super.component);

  /// Строит дерево компонентов с использованием ViewModel.
  ///
  /// Возвращает Component, который будет преобразован в Element через updateChild().
  Component build() {
    return component.build(_vm as dynamic);
  }

  @override
  void update(covariant ElementaryComponent newComponent) {
    super.update(newComponent);
    final oldComponent = _vm.componentInstance!;
    _vm
      ..componentInstance = newComponent
      ..didUpdateComponent(oldComponent);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vm.didChangeDependencies();
  }

  @override
  void activate() {
    super.activate();
    _vm.activate();
    markNeedsBuild();
  }

  @override
  void deactivate() {
    _vm.deactivate();
    super.deactivate();
  }

  @override
  void unmount() {
    // Сначала удаляем дочерний элемент
    if (_childElement != null) {
      updateChild(_childElement, null, _childElement!.slot);
      _childElement = null;
    }

    super.unmount();
    _vm
      ..dispose()
      ..element = null
      ..componentInstance = null;
  }

  @override
  void mount(Element? parent, ElementSlot newSlot) {
    super.mount(parent, newSlot);

    if (!_isInitialized) {
      _vm = component.wmFactory(this);
      _vm
        ..element = this
        ..componentInstance = component
        ..initViewModel()
        ..didChangeDependencies();

      _isInitialized = true;
    }

    // После инициализации нужно построить дочерний элемент
    _firstBuild();
  }

  /// Первый билд после mount
  void _firstBuild() {
    assert(_isInitialized);
    _childElement = updateChild(_childElement, build(), ElementSlot(0, null));
  }

  @override
  bool shouldRebuild(covariant Component newComponent) {
    // Всегда перестраиваем, так как ViewModel может измениться
    return true;
  }

  @override
  void performRebuild() {
    try {
      // Обновляем дочерний элемент с новым Component из build()
      _childElement = updateChild(_childElement, build(), ElementSlot(0, null));
    } catch (e, stack) {
      Error.throwWithStackTrace(e, stack);
    }
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_childElement != null) {
      visitor(_childElement!);
    }
  }

  @override
  bool get debugDoingBuild => false;
}
