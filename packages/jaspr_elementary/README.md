# jaspr_elementary

MVVM architecture for Jaspr applications, inspired by Flutter Elementary.

[![Pub Version](https://img.shields.io/pub/v/jaspr_elementary)](https://pub.dev/packages/jaspr_elementary)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Overview

`jaspr_elementary` provides tools for separating business logic and UI in Jaspr applications, following the principles of the Flutter `elementary` package. It implements the MVVM (Model-View-ViewModel) architecture pattern, making it easy to build maintainable, testable, and scalable web applications.

## Features

- **MVVM Architecture** — Clean separation of business logic, presentation logic, and UI
- **Lifecycle Management** — Automatic ComponentModel lifecycle management (init, update, dispose)
- **Reactive Agnostic** — Use any state management approach (Streams, ChangeNotifier, Riverpod, etc.)
- **SSR Compatible** — Works with Jaspr's server-side rendering
- **Flutter Elementary Compatible** — Familiar API for developers migrating from Flutter
- **Zero Dependencies** — Only depends on `jaspr` and `meta`
- **Testable** — Easy to unit test ComponentModels and Models independently

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  jaspr_elementary: ^0.3.0
```

Then run:

```bash
dart pub get
```

## Quick Start

### 1. Create a Business Logic Model

```dart
import 'package:jaspr_elementary/jaspr_elementary.dart';

class CounterModel extends ElementaryModel {
  int _count = 0;
  int get count => _count;

  final _countController = StreamController<int>.broadcast();
  Stream<int> get countStream => _countController.stream;

  void increment() {
    _count++;
    _countController.add(_count);
  }

  void decrement() {
    _count--;
    _countController.add(_count);
  }

  @override
  void dispose() {
    _countController.close();
    super.dispose();
  }
}
```

### 2. Create a ComponentModel

You can use a concrete ComponentModel class directly (simpler):

```dart
class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel> {
  CounterComponentModel(CounterModel model) : super(model);

  int get count => model.count;
  Stream<int> get countStream => model.countStream;

  void increment() => model.increment();
  void decrement() => model.decrement();
}
```

Or create an explicit interface for better documentation and testing:

```dart
abstract interface class ICounterComponentModel extends IComponentModel {
  int get count;
  Stream<int> get countStream;
  void increment();
  void decrement();
}

class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel>
    implements ICounterComponentModel {
  CounterComponentModel(CounterModel model) : super(model);

  @override
  int get count => model.count;

  @override
  Stream<int> get countStream => model.countStream;

  @override
  void increment() => model.increment();

  @override
  void decrement() => model.decrement();
}
```

### 3. Create a Component

```dart
class CounterComponent extends ElementaryComponent<CounterComponentModel> {
  const CounterComponent({
    super.key,
    ComponentModelFactory cmFactory = counterComponentModelFactory,
  }) : super(cmFactory);

  @override
  Component build(CounterComponentModel cm) {
    return Component.element(
      tag: 'div',
      classes: 'counter-container',
      children: [
        StreamBuilder<int>(
          stream: cm.countStream,
          initialData: cm.count,
          builder: (context, snapshot) {
            return Component.element(
              tag: 'p',
              children: [Component.text('Count: ${snapshot.data}')],
            );
          },
        ),
        Component.element(
          tag: 'button',
          events: {'click': (_) => cm.increment()},
          children: [Component.text('+')],
        ),
        Component.element(
          tag: 'button',
          events: {'click': (_) => cm.decrement()},
          children: [Component.text('-')],
        ),
      ],
    );
  }
}

// Factory function
CounterComponentModel counterComponentModelFactory(BuildContext context) {
  return CounterComponentModel(CounterModel());
}
```

### 4. Use the Component in Your App

```dart
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_elementary/jaspr_elementary.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessComponent {
  const MyApp({super.key});

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'body',
      children: [
        CounterComponent(),
      ],
    );
  }
}
```

## Architecture

### MVVM Pattern

```sh
┌─────────────────────────────────────────────────────────────┐
│                  Component (UI)                             │
│  - Describes how to render UI                               │
│  - Receives data from ComponentModel                        │
│  - Handles user interactions                                │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│               ComponentModel (Presentation)                 │
│  - Manages presentation state                               │
│  - Handles user interactions                                │
│  - Connects Model with Component                            │
│  - Lifecycle: init → update → dispose                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  ElementaryModel (Business Logic)           │
│  - Pure business logic                                      │
│  - No UI dependencies                                       │
│  - Testable independently                                   │
│  - Reports errors via handleError()                         │
└─────────────────────────────────────────────────────────────┘
```

### Element Lifecycle

```sh
mount() → initComponentModel() → didChangeDependencies() → build()
                               ↓
                     didUpdateComponent() (on update)
                               ↓
                          dispose() (on unmount)
```

| Method                    | Called When                             | Purpose                     |
| ------------------------- | --------------------------------------- | --------------------------- |
| `initComponentModel()`    | Once, before first build                | Initialize state, load data |
| `didChangeDependencies()` | After init, when inherited data changes | React to inherited data     |
| `didUpdateComponent()`    | When component configuration changes    | React to config changes     |
| `activate()`              | When reinserted after deactivate        | Resume operations           |
| `deactivate()`            | When temporarily removed from tree      | Pause operations            |
| `dispose()`               | Once, when permanently removed          | Clean up resources          |

## Usage Examples

### Error Handling

```dart
class DataModel extends ElementaryModel {
  Future<void> fetchData() async {
    try {
      final data = await api.getData();
      // Process data...
    } catch (error, stackTrace) {
      handleError(error, stackTrace: stackTrace);
    }
  }
}

class DataComponentModel extends ComponentModel<DataComponent, DataModel> {
  @override
  void onErrorHandle(Object error) {
    super.onErrorHandle(error);
    // Show error to user (snackbar, dialog, etc.)
    print('Error: $error');
  }
}
```

### Async Operations

```dart
class DataComponentModel extends ComponentModel<DataComponent, DataModel> {
  @override
  void initComponentModel() {
    super.initComponentModel();
    loadData();
  }

  Future<void> loadData() async {
    final data = await api.fetchData();
    if (isMounted) {
      // Safe to update state
      model.updateData(data);
    }
  }

  @override
  void dispose() {
    // Cancel pending operations
    super.dispose();
  }
}
```

### Using with ChangeNotifier

```dart
class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel>
    with ChangeNotifier {
  void increment() {
    model.increment();
    notifyListeners();
  }

  @override
  void dispose() {
    // Dispose ChangeNotifier
    super.dispose();
  }
}

// In component
ListenableBuilder(
  listenable: cm,
  builder: (context) {
    return Component.text('Count: ${cm.count}');
  },
)
```

### Using with DI Container

```dart
// Using get_it
CounterComponentModel counterComponentModelFactory(BuildContext context) {
  final model = getIt<CounterModel>();
  return CounterComponentModel(model);
}

// Using Riverpod
CounterComponentModel counterComponentModelFactory(BuildContext context) {
  final model = ref.read(counterModelProvider);
  return CounterComponentModel(model);
}
```

## Migration from Flutter Elementary

If you are familiar with the Flutter `elementary` package, here is the mapping:

| Flutter Elementary   | Jaspr Elementary        |
| -------------------- | ----------------------- |
| `Widget`             | `Component`             |
| `StatefulWidget`     | `StatefulComponent`     |
| `ElementaryWidget`   | `ElementaryComponent`   |
| `WidgetModel`        | `ComponentModel`        |
| `IWidgetModel`       | `IComponentModel`       |
| `ElementaryModel`    | `ElementaryModel`       |
| `WidgetModelFactory` | `ComponentModelFactory` |
| `BuildContext`       | `BuildContext`          |

### Code Migration Example

**Flutter:**

```dart
class CounterWidget extends ElementaryWidget<CounterWidgetModel> {
  @override
  Widget build(CounterWidgetModel cm) {
    return Scaffold(
      body: Text('Count: ${cm.count}'),
    );
  }
}
```

**Jaspr:**

```dart
class CounterComponent extends ElementaryComponent<CounterComponentModel> {
  @override
  Component build(CounterComponentModel cm) {
    return Component.element(
      tag: 'div',
      children: [Component.text('Count: ${cm.count}')],
    );
  }
}
```

## Best Practices

### 1. Keep Models Pure

`ElementaryModel` should not depend on UI frameworks:

```dart
// ✅ Good - Pure business logic
class CounterModel extends ElementaryModel {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
  }
}

// ❌ Bad - UI dependency
class CounterModel extends ElementaryModel {
  void increment() {
    // Don't access BuildContext or UI elements here
  }
}
```

### 2. Clean Up Resources

Always dispose of streams, subscriptions, and controllers:

```dart
class DataComponentModel extends ComponentModel<DataComponent, DataModel> {
  StreamSubscription? _subscription;

  @override
  void initComponentModel() {
    super.initComponentModel();
    _subscription = model.dataStream.listen((data) {
      // Process data
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

### 3. Use isMounted for Async Operations

```dart
class DataComponentModel extends ComponentModel<DataComponent, DataModel> {
  Future<void> loadData() async {
    final data = await api.fetchData();
    if (isMounted) {
      // Safe to update state
      model.updateData(data);
    }
  }
}
```

### 4. Use Interfaces for Large Projects

```dart
// Define explicit contract
abstract interface class IUserComponentModel extends IComponentModel {
  String get userName;
  bool get isLoading;
  Future<void> loadUser(String id);
}

// Implement contract
class UserComponentModel extends ComponentModel<UserComponent, UserModel>
    implements IUserComponentModel {
  // ...
}

// Use contract in component
class UserComponent extends ElementaryComponent<IUserComponentModel> {
  @override
  Component build(IUserComponentModel cm) {
    // ...
  }
}
```

### 5. Handle Errors Centrally

```dart
class ProductionErrorHandler implements ErrorHandler {
  @override
  void handleError(Object error, {StackTrace? stackTrace}) {
    // Send to monitoring service
    Sentry.captureException(error, stackTrace: stackTrace);
    // Log to file
    Logger.logError(error, stackTrace: stackTrace);
  }
}

class DataModel extends ElementaryModel {
  DataModel() : super(errorHandler: ProductionErrorHandler());
}
```

## Testing

Companion package [**jaspr_elementary_test**](https://github.com/san-smith/jaspr-elementary/tree/master/packages/jaspr_elementary_test) provides [`testComponentModel`](https://pub.dev/documentation/jaspr_elementary_test/latest/jaspr_elementary_test/testComponentModel.html) and related helpers, modelled after Flutter Elementary’s `elementary_test`.

### Unit Test ComponentModel

```dart
void main() {
  test('CounterComponentModel increments count', () {
    final model = CounterModel();
    final cm = CounterComponentModel(model);

    expect(cm.count, equals(0));

    cm.increment();

    expect(cm.count, equals(1));
  });

  test('CounterComponentModel handles errors', () {
    final model = CounterModel();
    final cm = CounterComponentModel(model);
    cm.initComponentModel();

    Object? capturedError;
    cm.setupTestError((error) => capturedError = error);

    model.handleError(Exception('Test error'));

    expect(capturedError, isA<Exception>());
  });
}
```

### Unit Test Model

```dart
void main() {
  test('CounterModel increments count', () {
    final model = CounterModel();

    expect(model.count, equals(0));

    model.increment();

    expect(model.count, equals(1));
  });

  test('CounterModel reports errors', () {
    final model = CounterModel();
    Object? capturedError;
    model.setupCmHandler((error) => capturedError = error);

    model.handleError(Exception('Test error'));

    expect(capturedError, isA<Exception>());
  });
}
```

## Additional Resources

- [GitHub Repository](https://github.com/san-smith/jaspr-elementary)
- [Examples](https://github.com/san-smith/jaspr-elementary/tree/main/example)
- [API Documentation](https://pub.dev/documentation/jaspr-elementary/latest/)
- [Issue Tracker](https://github.com/san-smith/jaspr-elementary/issues)

## License

This package is licensed under the [MIT License](LICENSE).
