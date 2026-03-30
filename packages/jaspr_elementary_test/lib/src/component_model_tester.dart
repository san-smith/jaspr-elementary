import 'package:jaspr/jaspr.dart';
import 'package:jaspr_elementary/jaspr_elementary.dart';

/// Controls [ComponentModel] lifecycle during tests (Jaspr analogue of Flutter
/// Elementary’s `WMTester` from package `elementary_test`).
abstract class ComponentModelTester<
  CM extends ComponentModel<C, M>,
  C extends ElementaryComponent,
  M extends ElementaryModel
> {
  /// Attaches [BuildContext], optional component, then [ComponentModel.initComponentModel]
  /// and [ComponentModel.didChangeDependencies] (same order as [ElementaryElement.mount]).
  ///
  /// If [initComponent] is null, do not call [update] afterward (there is no previous
  /// configuration to pass to [ComponentModel.didUpdateComponent]).
  void init({C? initComponent});

  /// Emulates a new [ElementaryComponent] configuration for the same model.
  void update(C newComponent);

  /// Emulates [Element.didChangeDependencies] for the model.
  void didChangeDependencies();

  /// Emulates [Element.activate] for the model.
  void activate();

  /// Emulates [Element.deactivate] for the model.
  void deactivate();

  /// Emulates permanent removal: [ComponentModel.dispose] and clears test element/component.
  void unmount();

  /// Emulates [ComponentModel.onErrorHandle] via [ComponentModel.handleTestError].
  void handleError(Object error);
}
