import 'package:jaspr/jaspr.dart';

import '../factory/view_model_factory.dart';
import '../view_model/i_view_model.dart';
import 'elementary_element.dart';

/// Базовый компонент для архитектуры MVVM.
abstract class ElementaryComponent<I extends IViewModel> extends Component {
  /// Фабрика для создания ViewModel.
  final ViewModelFactory wmFactory;

  const ElementaryComponent(this.wmFactory, {super.key});

  @override
  ElementaryElement createElement() {
    return ElementaryElement(this);
  }

  /// Описывает часть UI на основе состояния ViewModel.
  Component build(I vm);
}
