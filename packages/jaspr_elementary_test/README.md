# jaspr_elementary_test

Testing utilities for [`jaspr_elementary`](https://pub.dev/packages/jaspr_elementary).

## Requirements

- Dart `^3.10.7`
- [`jaspr_elementary`](https://pub.dev/packages/jaspr_elementary) `^0.3.0`
- [`jaspr`](https://pub.dev/packages/jaspr) `^0.22.x` (pulled in transitively; must stay compatible with [`jaspr_test`](https://pub.dev/packages/jaspr_test))

## Installation

```yaml
dev_dependencies:
  jaspr_elementary_test: ^0.2.0
  # test is re-exported by jaspr_test; you may add package:test explicitly if you prefer
```

## `testComponentModel`

Runs a test with a fresh [ComponentModel](https://pub.dev/documentation/jaspr_elementary/latest/jaspr_elementary/ComponentModel-class.html), a [ComponentModelTester](https://pub.dev/documentation/jaspr_elementary_test/latest/jaspr_elementary_test/ComponentModelTester-class.html), and a real `BuildContext` from a short-lived Jaspr subtree. This mirrors Flutter Elementary’s `testWidgetModel` from package `elementary_test`.

```dart
import 'package:jaspr_elementary_test/jaspr_elementary_test.dart';

testComponentModel<MyCm, MyComponent, MyModel>(
  'loads data',
  () => MyCm(MyModel()),
  (cm, tester, context) async {
    tester.init(initComponent: MyComponent());
    // use context / cm …
    tester.unmount();
  },
);
```

Call [`ComponentModelTester.unmount`](https://pub.dev/documentation/jaspr_elementary_test/latest/jaspr_elementary_test/ComponentModelTester/unmount.html) when finished so the model is disposed. If [init](https://pub.dev/documentation/jaspr_elementary_test/latest/jaspr_elementary_test/ComponentModelTester/init.html) used a null `initComponent`, do not call [update](https://pub.dev/documentation/jaspr_elementary_test/latest/jaspr_elementary_test/ComponentModelTester/update.html) afterward.

## Development (monorepo)

This package lives next to `jaspr_elementary` in the [repository](https://github.com/san-smith/jaspr-elementary).

For a local path dependency on `jaspr_elementary`, add **`pubspec_overrides.yaml`** (gitignored in this repo):

```yaml
dependency_overrides:
  jaspr_elementary:
    path: ../jaspr_elementary
```

```bash
cd packages/jaspr_elementary_test
dart pub get
dart analyze
dart test
```

## Publishing

Publish **`jaspr_elementary`** satisfying the `jaspr_elementary` constraint in `pubspec.yaml` before publishing this package.

```bash
dart pub publish --dry-run
dart pub publish
```
