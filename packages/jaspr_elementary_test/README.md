# jaspr_elementary_test

Testing utilities for [`jaspr_elementary`](https://pub.dev/packages/jaspr_elementary).

## Requirements

- Dart `^3.10.7`
- [`jaspr_elementary`](https://pub.dev/packages/jaspr_elementary) `^0.3.0`
- [`jaspr`](https://pub.dev/packages/jaspr) `^0.22.2`

## Status

Initial release: package scaffold. Helpers such as `testComponentModel` (analogue of Flutter Elementary’s `testWidgetModel`) will be added in follow-up versions.

## Installation

```yaml
dev_dependencies:
  jaspr_elementary_test: ^0.1.0
```

Then `dart pub get`.

## Development (monorepo)

This package lives next to `jaspr_elementary` in the [repository](https://github.com/san-smith/jaspr-elementary).

If `jaspr_elementary` is not yet published at the version declared in `pubspec.yaml`, or you are changing both packages at once, add a **`pubspec_overrides.yaml`** next to this package’s `pubspec.yaml` (this file is gitignored in this repo):

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
