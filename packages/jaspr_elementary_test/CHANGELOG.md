# Changelog

All notable changes to the `jaspr_elementary_test` package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-03-30

### Added

- [`testComponentModel`](https://pub.dev/documentation/jaspr_elementary_test/latest/jaspr_elementary_test/testComponentModel.html) — analogue of Flutter Elementary’s `testWidgetModel`; builds a minimal Jaspr tree to obtain a real [BuildContext] (Jaspr’s `BuildContext` is sealed).
- [`ComponentModelTester`](https://pub.dev/documentation/jaspr_elementary_test/latest/jaspr_elementary_test/ComponentModelTester-class.html) and [`ComponentModelHarness`](https://pub.dev/documentation/jaspr_elementary_test/latest/jaspr_elementary_test/ComponentModelHarness-class.html) — lifecycle helpers aligned with [`ElementaryElement`](https://pub.dev/documentation/jaspr_elementary/latest/jaspr_elementary/ElementaryElement-class.html).
- Dependency on [`jaspr_test`](https://pub.dev/packages/jaspr_test) for [`TestComponentsBinding`](https://pub.dev/documentation/jaspr_test/latest/jaspr_test/TestComponentsBinding-class.html).

## [0.1.0] - 2026-03-30

### Added

- Initial pub.dev–ready scaffold: dependency on `jaspr_elementary` ^0.3.0.
