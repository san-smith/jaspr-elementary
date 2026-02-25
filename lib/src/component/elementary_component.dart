import 'package:jaspr/jaspr.dart';

import '../factory/view_model_factory.dart';
import '../view_model/i_view_model.dart';
import 'elementary_element.dart';

/// A base component for MVVM architecture.
///
/// [ElementaryComponent] uses a [ViewModel] to build the UI.
/// The ViewModel provides data and methods for interaction,
/// while the component only describes how they are rendered.
///
/// ## Type parameters
/// - [I] — the ViewModel interface used by this component
///
/// ## Structure
/// ```dart
/// class MyComponent extends ElementaryComponent<IMyViewModel> {
///   const MyComponent({
///     super.key,
///     ViewModelFactory wmFactory = myViewModelFactory,
///   }) : super(wmFactory);
///
///   @override
///   Component build(IMyViewModel vm) {
///     return Component.element(tag: 'div', children: [
///       Component.text('Hello, ${vm.name}'),
///       Component.element(
///         tag: 'button',
///         events: {'click': (_) => vm.onTap()},
///         children: [Component.text('Click')],
///       ),
///     ]);
///   }
/// }
/// ```
///
/// ## Important principles
/// - The [build()] method should be a pure function of the ViewModel
/// - Do not access external data sources in [build()]
/// - All data must come from the ViewModel
///
/// ## Optional interface
/// You can use a specific ViewModel class directly without creating an interface:
/// ```dart
/// class CounterViewModel extends ViewModel<CounterComponent, CounterModel> {
///   // ...
/// }
///
/// class CounterComponent extends ElementaryComponent<CounterViewModel> {
///   @override
///   Component build(CounterViewModel vm) {
///     // ...
///   }
/// }
/// ```
///
/// Or create an explicit interface for better documentation and testing:
/// ```dart
/// abstract interface class ICounterViewModel extends IViewModel {
///   int get count;
///   void increment();
/// }
///
/// class CounterViewModel extends ViewModel<CounterComponent, CounterModel>
///     implements ICounterViewModel {
///   // ...
/// }
///
/// class CounterComponent extends ElementaryComponent<ICounterViewModel> {
///   @override
///   Component build(ICounterViewModel vm) {
///     // ...
///   }
/// }
/// ```
///
/// ## wmFactory
/// A factory for creating the ViewModel. By default, a global function is used,
/// but it can be overridden for tests or special cases.
///
/// See also:
///
///  * [ViewModel], for the base class of presentation logic
///  * [ElementaryElement], for the element that manages the ViewModel lifecycle
///  * [ViewModelFactory], for the factory function type
abstract class ElementaryComponent<I extends IViewModel> extends Component {
  /// The factory function used to create a ViewModel.
  ///
  /// Can be overridden in the constructor for testing or providing
  /// an alternative ViewModel implementation.
  ///
  /// ## Example
  /// ```dart
  /// // Default factory
  /// const MyComponent() : super(myViewModelFactory);
  ///
  /// // Custom factory for tests
  /// MyComponent.test() : super(mockViewModelFactory);
  /// ```
  final ViewModelFactory wmFactory;

  /// Creates an instance of ElementaryComponent with the specified ViewModel factory.
  ///
  /// ## Parameters
  /// - [wmFactory] — factory for creating the ViewModel
  /// - [key] — component key (optional)
  const ElementaryComponent(this.wmFactory, {super.key});

  /// Creates an [ElementaryElement] to manage this component.
  ///
  /// This method is overridden to use a custom Element that manages
  /// the ViewModel lifecycle.
  ///
  /// It is uncommon for subclasses to override this method.
  @override
  ElementaryElement createElement() {
    return ElementaryElement(this);
  }

  /// Describes the part of the user interface based on the ViewModel state.
  ///
  /// This method should be a pure function: it receives a ViewModel and
  /// returns a component tree. No side effects.
  ///
  /// ## Parameters
  /// - [vm] — ViewModel instance with data and methods
  ///
  /// ## Returns
  /// - [Component] — the root component of the UI tree
  ///
  /// ## Important
  /// - No access to BuildContext in this method
  /// - All data must come from the ViewModel
  /// - The method may be called frequently, avoid heavy operations
  ///
  /// ## Example
  /// ```dart
  /// @override
  /// Component build(CounterViewModel vm) {
  ///   return Component.element(
  ///     tag: 'div',
  ///     children: [
  ///       Component.text('Count: ${vm.count}'),
  ///       Component.element(
  ///         tag: 'button',
  ///         events: {'click': (_) => vm.increment()},
  ///         children: [Component.text('+')],
  ///       ),
  ///     ],
  ///   );
  /// }
  /// ```
  Component build(I vm);
}
