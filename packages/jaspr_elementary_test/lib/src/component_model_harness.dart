// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_elementary/jaspr_elementary.dart';

import 'component_model_tester.dart';

/// Drives [ComponentModel] through the same lifecycle sequence as [ElementaryElement].
final class ComponentModelHarness<
  CM extends ComponentModel<C, M>,
  C extends ElementaryComponent,
  M extends ElementaryModel
> implements ComponentModelTester<CM, C, M> {
  ComponentModelHarness(this._cm, this._context);

  final CM _cm;
  final BuildContext _context;

  /// Last component passed to [init] or [update]; mirrors [ElementaryElement] state.
  C? _configuredComponent;

  @override
  void init({C? initComponent}) {
    _configuredComponent = initComponent;
    _cm
      ..setupTestElement(_context)
      ..setupTestComponent(initComponent)
      ..initComponentModel()
      ..didChangeDependencies();
  }

  @override
  void update(C newComponent) {
    final oldComponent = _configuredComponent;
    if (oldComponent == null) {
      throw StateError(
        'ComponentModelTester.update requires init() to have been called '
        'with a non-null initComponent.',
      );
    }
    _configuredComponent = newComponent;
    _cm
      ..setupTestComponent(newComponent)
      ..didUpdateComponent(oldComponent);
  }

  @override
  void didChangeDependencies() {
    _cm.didChangeDependencies();
  }

  @override
  void activate() {
    _cm.activate();
  }

  @override
  void deactivate() {
    _cm.deactivate();
  }

  @override
  void unmount() {
    _configuredComponent = null;
    _cm
      ..dispose()
      ..setupTestElement(null)
      ..setupTestComponent(null);
  }

  @override
  void handleError(Object error) {
    _cm.handleTestError(error);
  }
}
