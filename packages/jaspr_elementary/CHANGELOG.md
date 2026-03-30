# Changelog

All notable changes to the `jaspr_elementary` package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Repository layout: the package now lives under `packages/jaspr_elementary/` in a monorepo. The companion package `jaspr_elementary_test` is under `packages/jaspr_elementary_test/`. Published API and pub package name are unchanged.

## [0.2.0] - 2025-02-26

### ⚠️ Breaking Changes

#### Class and Method Renaming for Flutter Elementary Compatibility

To achieve better alignment with the Flutter `elementary` package naming conventions and improve consistency across platforms, the following classes and methods have been renamed:

| Previous Name (v0.1.x) | New Name (v0.2.0)       |
| ---------------------- | ----------------------- |
| `ViewModel`            | `ComponentModel`        |
| `IViewModel`           | `IComponentModel`       |
| `initViewModel()`      | `initComponentModel()`  |
| `vmFactory`            | `cmFactory`             |
| `ViewModelFactory`     | `ComponentModelFactory` |
| `setupVmHandler()`     | `setupCmHandler()`      |
| `_vm` (internal field) | `_cm` (internal field)  |

**Files and Directories Renamed:**

| Previous Path                             | New Path                                         |
| ----------------------------------------- | ------------------------------------------------ |
| `lib/src/view_model/`                     | `lib/src/component_model/`                       |
| `lib/src/view_model/view_model.dart`      | `lib/src/component_model/component_model.dart`   |
| `lib/src/view_model/i_view_model.dart`    | `lib/src/component_model/i_component_model.dart` |
| `lib/src/factory/view_model_factory.dart` | `lib/src/factory/component_model_factory.dart`   |

**Why This Change?**

This renaming brings several benefits:

1. **Better Flutter Elementary Compatibility** — The naming now matches the original Flutter `elementary` package more closely, making it easier for developers to migrate between platforms.

2. **Clearer Naming** — `ComponentModel` more accurately reflects that this class is tied to a Jaspr `Component`, not a generic `ViewModel` concept.

3. **Consistency** — All related classes, methods, and files now follow a consistent naming convention.

## [0.1.0] - 2025-02-25

### Added

- **Core MVVM Architecture**
  - `ElementaryComponent` — Base component for MVVM architecture with ViewModel integration
  - `ViewModel` — Base class for presentation logic with lifecycle management
  - `ElementaryModel` — Base class for business logic (UI-independent)
  - `IViewModel` — Marker interface for all ViewModels
  - `ElementaryElement` — Custom Element that manages ViewModel lifecycle

- **Lifecycle Management**
  - `initViewModel()` — Called once before first build
  - `didUpdateComponent()` — Called when component configuration changes
  - `didChangeDependencies()` — Called when inherited dependencies change
  - `activate()` / `deactivate()` — Called when ViewModel enters/exits the tree
  - `dispose()` — Called when ViewModel is permanently removed

- **Error Handling**
  - `ErrorHandler` interface for centralized error handling
  - `ElementaryModel.handleError()` for reporting errors from business logic
  - `ViewModel.onErrorHandle()` for UI-layer error reactions

- **ViewModel Factory**
  - `ViewModelFactory` typedef for creating ViewModel instances
  - Support for custom factories (useful for testing and DI)

- **BuildContext Access**
  - `ViewModel.context` getter for accessing BuildContext
  - `ViewModel.isMounted` for checking if ViewModel is still active

- **Testing Support**
  - `setupTestComponent()` for mocking components in tests
  - `setupTestElement()` for mocking BuildContext in tests
  - `handleTestError()` for testing error handling

- **Documentation**
  - Comprehensive dartdoc comments for all public APIs
  - README.md with quick start guide and examples
  - Example counter application in `example/counter_app`

### Features

- **Reactive Agnostic** — Works with any state management approach (Streams, ChangeNotifier, ValueNotifier, Riverpod, etc.)
- **SSR Compatible** — Designed to work with Jaspr's server-side rendering
- **Zero Dependencies** — Only depends on `jaspr` (^0.22.2) and `meta`
- **Flutter Elementary Compatible** — Familiar API for developers migrating from Flutter `elementary` package

### Migration Guide

For developers familiar with Flutter `elementary`:

| Flutter Elementary   | Jaspr Elementary      |
| -------------------- | --------------------- |
| `Widget`             | `Component`           |
| `StatefulWidget`     | `StatefulComponent`   |
| `ElementaryWidget`   | `ElementaryComponent` |
| `WidgetModel`        | `ViewModel`           |
| `IWidgetModel`       | `IViewModel`          |
| `ElementaryModel`    | `ElementaryModel`     |
| `WidgetModelFactory` | `ViewModelFactory`    |

### Known Limitations

- **No built-in reactive primitives** — This package does not include Stream, ChangeNotifier, or other reactive primitives. Use Dart's built-in `Stream` or third-party packages as needed.
- **No navigation service** — Navigation is not included. Implement your own navigation abstraction or use `jaspr_router`.
- **No built-in DI container** — Use external DI solutions (get_it, Riverpod, etc.) or manual dependency injection via factories.

### Example Usage

```dart
// Model
class CounterModel extends ElementaryModel {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    // Notify UI via Stream, ChangeNotifier, etc.
  }
}

// ViewModel
class CounterViewModel extends ViewModel<CounterComponent, CounterModel> {
  CounterViewModel(CounterModel model) : super(model);

  int get count => model.count;
  void increment() => model.increment();
}

// Component
class CounterComponent extends ElementaryComponent<CounterViewModel> {
  const CounterComponent({
    super.key,
    ViewModelFactory wmFactory = counterViewModelFactory,
  }) : super(wmFactory);

  @override
  Component build(CounterViewModel vm) {
    return Component.element(
      tag: 'div',
      children: [
        Component.text('Count: ${vm.count}'),
        Component.element(
          tag: 'button',
          events: {'click': (_) => vm.increment()},
          children: [Component.text('+')],
        ),
      ],
    );
  }
}
```

### Requirements

- Dart SDK: ^3.10.0
- Jaspr: ^0.22.2

### Links

- [GitHub Repository](https://github.com/san-smith/jaspr_elementary)
- [Examples](https://github.com/san-smith/jaspr_elementary/tree/main/example)
- [API Documentation](https://pub.dev/documentation/jaspr_elementary/latest/)
- [Report Issues](https://github.com/san-smith/jaspr_elementary/issues)

---

_For more information about this package, visit [pub.dev/packages/jaspr_elementary](https://pub.dev/packages/jaspr_elementary)._
