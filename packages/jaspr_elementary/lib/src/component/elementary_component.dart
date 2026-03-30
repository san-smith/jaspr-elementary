import 'package:jaspr/jaspr.dart';

import '../component_model/i_component_model.dart';
import '../factory/component_model_factory.dart';
import 'elementary_element.dart';

/// A base component for MVVM architecture.
///
/// [ElementaryComponent] uses a [ComponentModel] to build the UI.
/// The ComponentModel provides data and methods for interaction,
/// while the component only describes how they are rendered.
///
/// ## Type parameters
/// - [I] — the ComponentModel interface used by this component
///
/// ## Structure
/// ```dart
/// class MyComponent extends ElementaryComponent<IMyComponentModel> {
///   const MyComponent({
///     super.key,
///     ComponentModelFactory cmFactory = myComponentModelFactory,
///   }) : super(cmFactory);
///
///   @override
///   Component build(IMyComponentModel cm) {
///     return Component.element(tag: 'div', children: [
///       Component.text('Hello, ${cm.name}'),
///       Component.element(
///         tag: 'button',
///         events: {'click': (_) => cm.onTap()},
///         children: [Component.text('Click')],
///       ),
///     ]);
///   }
/// }
/// ```
///
/// ## Important principles
/// - The [build()] method should be a pure function of the ComponentModel
/// - Do not access external data sources in [build()]
/// - All data must come from the ComponentModel
///
/// ## Optional interface
/// You can use a specific ComponentModel class directly without creating an interface:
/// ```dart
/// class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel> {
///   // ...
/// }
///
/// class CounterComponent extends ElementaryComponent<CounterComponentModel> {
///   @override
///   Component build(CounterComponentModel cm) {
///     // ...
///   }
/// }
/// ```
///
/// Or create an explicit interface for better documentation and testing:
/// ```dart
/// abstract interface class ICounterComponentModel extends IComponentModel {
///   int get count;
///   void increment();
/// }
///
/// class CounterComponentModel extends ComponentModel<CounterComponent, CounterModel>
///     implements ICounterComponentModel {
///   // ...
/// }
///
/// class CounterComponent extends ElementaryComponent<ICounterComponentModel> {
///   @override
///   Component build(ICounterComponentModel cm) {
///     // ...
///   }
/// }
/// ```
///
/// ## cmFactory
/// A factory for creating the ComponentModel. By default, a global function is used,
/// but it can be overridden for tests or special cases.
///
/// See also:
///
///  * [ComponentModel], for the base class of presentation logic
///  * [ElementaryElement], for the element that manages the ComponentModel lifecycle
///  * [ComponentModelFactory], for the factory function type
abstract class ElementaryComponent<I extends IComponentModel>
    extends Component {
  /// The factory function used to create a ComponentModel.
  ///
  /// Can be overridden in the constructor for testing or providing
  /// an alternative ComponentModel implementation.
  ///
  /// ## Example
  /// ```dart
  /// // Default factory
  /// const MyComponent() : super(myComponentModelFactory);
  ///
  /// // Custom factory for tests
  /// MyComponent.test() : super(mockComponentModelFactory);
  /// ```
  final ComponentModelFactory cmFactory;

  /// Creates an instance of ElementaryComponent with the specified ComponentModel factory.
  ///
  /// ## Parameters
  /// - [cmFactory] — factory for creating the ComponentModel
  /// - [key] — component key (optional)
  const ElementaryComponent(this.cmFactory, {super.key});

  /// Creates an [ElementaryElement] to manage this component.
  ///
  /// This method is overridden to use a custom Element that manages
  /// the ComponentModel lifecycle.
  ///
  /// It is uncommon for subclasses to override this method.
  @override
  ElementaryElement createElement() {
    return ElementaryElement(this);
  }

  /// Describes the part of the user interface based on the ComponentModel state.
  ///
  /// This method should be a pure function: it receives a ComponentModel and
  /// returns a component tree. No side effects.
  ///
  /// ## Parameters
  /// - [cm] — ComponentModel instance with data and methods
  ///
  /// ## Returns
  /// - [Component] — the root component of the UI tree
  ///
  /// ## Important
  /// - No access to BuildContext in this method
  /// - All data must come from the ComponentModel
  /// - The method may be called frequently, avoid heavy operations
  ///
  /// ## Example
  /// ```dart
  /// @override
  /// Component build(CounterComponentModel cm) {
  ///   return Component.element(
  ///     tag: 'div',
  ///     children: [
  ///       Component.text('Count: ${cm.count}'),
  ///       Component.element(
  ///         tag: 'button',
  ///         events: {'click': (_) => cm.increment()},
  ///         children: [Component.text('+')],
  ///       ),
  ///     ],
  ///   );
  /// }
  /// ```
  Component build(I cm);
}
