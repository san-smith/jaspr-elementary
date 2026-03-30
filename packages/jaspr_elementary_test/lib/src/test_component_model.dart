import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_elementary/jaspr_elementary.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:meta/meta.dart';

import 'component_model_harness.dart';
import 'component_model_tester.dart';
import 'context_capture_component.dart';

/// Runs a test with a [ComponentModel] and a [ComponentModelTester], similar to
/// Flutter Elementary’s [testWidgetModel](https://pub.dev/documentation/elementary_test/latest/elementary_test/testWidgetModel.html).
///
/// A short-lived Jaspr component tree is built so [BuildContext] is a real
/// [Element] (Jaspr’s [BuildContext] is sealed; mocks cannot implement it).
///
/// Typical usage:
/// ```dart
/// testComponentModel<CounterComponentModel, CounterComponent, CounterModel>(
///   'increments',
///   () => CounterComponentModel(CounterModel()),
///   (cm, tester, context) async {
///     tester.init(initComponent: CounterComponent());
///     expect(cm.count, 0);
///     cm.increment();
///     expect(cm.count, 1);
///     tester.unmount();
///   },
/// );
/// ```
@isTest
void testComponentModel<
  CM extends ComponentModel<C, M>,
  C extends ElementaryComponent,
  M extends ElementaryModel
>(
  String description,
  CM Function() setupCm,
  FutureOr<void> Function(
    CM cm,
    ComponentModelTester<CM, C, M> tester,
    BuildContext context,
  )
  testFunction, {
  String? testOn,
  Timeout? timeout,
  // ignore: avoid_annotating_with_dynamic
  dynamic skip,
  // ignore: avoid_annotating_with_dynamic
  dynamic tags,
  Map<String, dynamic>? onPlatform,
  int? retry,
}) {
  test(
    description,
    () async {
      BuildContext? capturedContext;

      final binding = TestComponentsBinding('/', true);
      binding.attachRootComponent(
        ContextCaptureComponent((ctx) => capturedContext = ctx),
      );

      await pumpEventQueue();

      final context = capturedContext;
      if (context == null) {
        fail(
          'jaspr_elementary_test: BuildContext was not captured. '
          'Try awaiting additional microtasks (e.g. pumpEventQueue) if using async build.',
        );
      }

      final cm = setupCm();
      final tester = ComponentModelHarness<CM, C, M>(cm, context);

      await testFunction(cm, tester, context);
    },
    testOn: testOn,
    timeout: timeout,
    skip: skip,
    tags: tags,
    onPlatform: onPlatform,
    retry: retry,
  );
}
