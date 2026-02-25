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
final class ElementaryElement extends Element {
  @override
  ElementaryComponent get component => super.component as ElementaryComponent;

  late ViewModel _vm;
  bool _isInitialized = false;

  ElementaryElement(ElementaryComponent super.component);

  /// Строит дерево компонентов с использованием ViewModel.
  ///
  /// Не является @override, так как в Element нет абстрактного build()
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
  }

  @override
  bool shouldRebuild(covariant Component newComponent) {
    // Всегда перестраиваем, так как ViewModel может измениться
    return true;
  }

  @override
  void performRebuild() {
    // Просто отмечаем как не dirty, rebuild вызывается из BuildOwner
    // Не обращаемся к _dirty напрямую - это приватное поле Element
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    // У ElementaryElement нет дочерних элементов для посещения
    // Компонент строится через build(), но дети управляются Jaspr
  }

  @override
  bool get debugDoingBuild => false;
}
