# jaspr-elementary (monorepo)

MVVM architecture for [Jaspr](https://pub.dev/packages/jaspr), inspired by [Flutter Elementary](https://pub.dev/packages/elementary).

## Packages

| Package                                                    | Description                                                              | Pub                                                                                                |
| ---------------------------------------------------------- | ------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| [`jaspr_elementary`](packages/jaspr_elementary/)           | Core library: `ElementaryModel`, `ComponentModel`, `ElementaryComponent` | [![Pub](https://img.shields.io/pub/v/jaspr_elementary)](https://pub.dev/packages/jaspr_elementary) |
| [`jaspr_elementary_test`](packages/jaspr_elementary_test/) | Testing utilities (e.g. `testComponentModel` — planned)                  | _not yet on pub.dev_                                                                               |

## Repository layout

```text
packages/jaspr_elementary/       # main package (pub name: jaspr_elementary)
packages/jaspr_elementary_test/  # test helpers (pub name: jaspr_elementary_test)
example/counter/                 # sample app
```

## Contributing / development

From each package directory, run `dart pub get` and `dart analyze` as usual:

```bash
cd packages/jaspr_elementary && dart pub get && dart analyze
cd packages/jaspr_elementary_test && dart pub get && dart analyze && dart test
```

Run the example:

```bash
cd example/counter && dart pub get && dart run jaspr build
```

## License

MIT — see [LICENSE](LICENSE).
