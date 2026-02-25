import 'package:jaspr/jaspr.dart';

import '../view_model/view_model.dart';

/// Тип фабрики для создания экземпляра [ViewModel].
typedef ViewModelFactory<T extends ViewModel> =
    T Function(BuildContext context);
