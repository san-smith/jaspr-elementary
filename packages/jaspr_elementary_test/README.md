# jaspr_elementary_test

Testing utilities for [`jaspr_elementary`](https://pub.dev/packages/jaspr_elementary).

This package lives in the [jaspr-elementary monorepo](https://github.com/san-smith/jaspr-elementary) next to the main library. It currently ships as **`publish_to: none`** because it depends on `jaspr_elementary` via a path dependency. When you publish to pub.dev, replace that with a normal version constraint and remove `publish_to: none`.

## Status

Scaffold only: `testComponentModel` and related APIs will be added in follow-up work.

## Development

```bash
cd packages/jaspr_elementary_test
dart pub get
dart analyze
dart test
```
