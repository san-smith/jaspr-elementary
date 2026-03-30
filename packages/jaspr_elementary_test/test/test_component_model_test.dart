import 'package:jaspr/jaspr.dart';
import 'package:jaspr_elementary/jaspr_elementary.dart';
import 'package:jaspr_elementary_test/jaspr_elementary_test.dart';
import 'package:test/test.dart';

class _Model extends ElementaryModel {}

class _Comp extends ElementaryComponent<_Cm> {
  _Comp() : super((_) => throw StateError('cmFactory is not used in this test'));

  @override
  Component build(_Cm cm) => Component.text('');
}

class _Cm extends ComponentModel<_Comp, _Model> {
  _Cm(super.model);

  final log = <String>[];
  Object? lastError;

  @override
  void initComponentModel() {
    log.add('initComponentModel');
    super.initComponentModel();
  }

  @override
  void didChangeDependencies() {
    log.add('didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  void didUpdateComponent(_Comp oldComponent) {
    log.add('didUpdateComponent');
    super.didUpdateComponent(oldComponent);
  }

  @override
  void onErrorHandle(Object error) {
    lastError = error;
    super.onErrorHandle(error);
  }

  @override
  void dispose() {
    log.add('dispose');
    super.dispose();
  }
}

class _Comp2 extends _Comp {}

void main() {
  testComponentModel<_Cm, _Comp, _Model>(
    'init runs model setup then didChangeDependencies',
    () => _Cm(_Model()),
    (cm, tester, context) async {
      expect(context, isNotNull);

      tester.init(initComponent: _Comp());

      expect(cm.log, [
        'initComponentModel',
        'didChangeDependencies',
      ]);
      expect(cm.model, isNotNull);

      tester.unmount();
      expect(cm.log.last, 'dispose');
    },
  );

  testComponentModel<_Cm, _Comp, _Model>(
    'update calls didUpdateComponent',
    () => _Cm(_Model()),
    (cm, tester, context) async {
      final first = _Comp();
      final second = _Comp2();

      tester.init(initComponent: first);
      cm.log.clear();

      tester.update(second);

      expect(cm.log, ['didUpdateComponent']);
      expect(identical(cm.component, second), isTrue);

      tester.unmount();
    },
  );

  testComponentModel<_Cm, _Comp, _Model>(
    'handleError forwards to onErrorHandle',
    () => _Cm(_Model()),
    (cm, tester, context) async {
      tester.init(initComponent: _Comp());

      tester.handleError('e1');
      expect(cm.lastError, 'e1');

      tester.unmount();
    },
  );
}
