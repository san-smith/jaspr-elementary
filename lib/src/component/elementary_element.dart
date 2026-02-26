import 'package:jaspr/jaspr.dart';

import '../component_model/component_model.dart';
import 'elementary_component.dart';

/// An element that manages the lifecycle of a ComponentModel.
///
/// [ElementaryElement] is a custom [Element] that:
/// - Creates a ComponentModel once during the first build
/// - Preserves the ComponentModel when the component is recreated
/// - Calls ComponentModel lifecycle methods
/// - Destroys the ComponentModel when removed from the tree
/// - Creates and manages a child [Element] from the [Component]
///
/// ## Lifecycle overview
/// ```
/// mount() → _firstBuild() → build() → performRebuild()
///                              ↓
///                    update() (when component changes)
///                              ↓
///                    unmount() (cleanup and dispose)
/// ```
///
/// ## Architecture
/// ```
/// ┌─────────────────────────────────────────┐
/// │         ElementaryElement               │
/// │  ┌───────────────────────────────────┐  │
/// │  │           ComponentModel          │  │
/// │  │  (created once, lives long)       │  │
/// │  └───────────────────────────────────┘  │
/// │                                         │
/// │  ┌───────────────────────────────────┐  │
/// │  │      _childElement                │  │
/// │  │  (managed via updateChild())      │  │
/// │  └───────────────────────────────────┘  │
/// └─────────────────────────────────────────┘
/// ```
///
/// ## Important
/// This class should not be used directly by developers.
/// It is created automatically when using [ElementaryComponent].
///
/// See also:
///
///  * [ElementaryComponent], for the component that uses this element
///  * [ComponentModel], for the base class of presentation logic
///  * [Element], for the base class in Jaspr
final class ElementaryElement extends Element {
  @override
  ElementaryComponent get component => super.component as ElementaryComponent;

  /// The ComponentModel instance managed by this element.
  ///
  /// Created once during [mount()] and disposed during [unmount()].
  late ComponentModel _cm;

  /// Whether the ComponentModel has been initialized.
  ///
  /// Used to ensure the ComponentModel is created only once during the element's lifetime.
  bool _isInitialized = false;

  /// The child element created from the [Component] returned by [build()].
  ///
  /// This element is managed via [updateChild()] and represents the actual UI
  /// component tree built by the [ElementaryComponent].
  Element? _childElement;

  /// Creates an instance of ElementaryElement.
  ///
  /// ## Parameters
  /// - [component] — the component that will be managed by this element
  ElementaryElement(ElementaryComponent super.component);

  /// Builds the component tree using the ComponentModel.
  ///
  /// Returns a [Component] that will be converted to an [Element] via [updateChild()].
  /// This method delegates to [ElementaryComponent.build()] passing the ComponentModel.
  ///
  /// ## Returns
  /// - [Component] — the root component of the UI tree
  ///
  /// ## Important
  /// This is not an override method. It is called internally by [performRebuild()]
  /// and [_firstBuild()].
  ///
  /// ## Example
  /// ```dart
  /// Component build() {
  ///   return component.build(_cm as dynamic);
  /// }
  /// ```
  Component build() {
    return component.build(_cm as dynamic);
  }

  /// Updates the element with a new component configuration.
  ///
  /// Called when the parent rebuilds and creates a new instance of the component.
  /// The ComponentModel is preserved, but notified about the component update.
  ///
  /// ## Parameters
  /// - [newComponent] — the new component configuration
  ///
  /// ## Lifecycle
  /// This method calls [ComponentModel.didUpdateComponent()] to notify the ComponentModel
  /// about the component change. The ComponentModel can then decide whether to
  /// update its state based on the new component configuration.
  ///
  /// ## Important
  /// The ComponentModel is NOT recreated during this method. It continues to live
  /// with the same state it had before the update.
  @override
  void update(covariant ElementaryComponent newComponent) {
    super.update(newComponent);
    final oldComponent = _cm.componentInstance!;
    _cm
      ..componentInstance = newComponent
      ..didUpdateComponent(oldComponent);
  }

  /// Called when a dependency of this element changes.
  ///
  /// Dependencies are data obtained from [InheritedComponent] via [BuildContext].
  /// When an inherited component updates and notifies its dependents, this method
  /// is called to notify the ComponentModel.
  ///
  /// ## Lifecycle
  /// This method is also called immediately after [initComponentModel()] during
  /// the first build.
  ///
  /// ## Important
  /// This method marks the element as needing rebuild via [markNeedsBuild()].
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cm.didChangeDependencies();
  }

  /// Transitions from the "inactive" to the "active" lifecycle state.
  ///
  /// Called when a previously deactivated element is reinserted into the tree.
  /// The ComponentModel is notified via [ComponentModel.activate()] and the element is
  /// marked as needing rebuild.
  ///
  /// ## Lifecycle
  /// This method is NOT called the first time an element becomes active.
  /// Instead, [mount()] is called in that situation.
  ///
  /// ## Important
  /// Always call `super.activate()` in overrides.
  @override
  void activate() {
    super.activate();
    _cm.activate();
    markNeedsBuild();
  }

  /// Transitions from the "active" to the "inactive" lifecycle state.
  ///
  /// Called when the element is temporarily removed from the tree.
  /// The element can remain in the inactive state only until the end of the
  /// current animation frame. If not reactivated, it will be unmounted.
  ///
  /// ## Lifecycle
  /// The ComponentModel is notified via [ComponentModel.deactivate()].
  ///
  /// ## Important
  /// Always call `super.deactivate()` in overrides.
  @override
  void deactivate() {
    _cm.deactivate();
    super.deactivate();
  }

  /// Transitions from the "inactive" to the "defunct" lifecycle state.
  ///
  /// Called when the element is permanently removed from the tree.
  /// After this method is called, the element will not be incorporated into
  /// the tree again.
  ///
  /// ## Cleanup
  /// - Removes the child element via [updateChild()]
  /// - Disposes the ComponentModel via [ComponentModel.dispose()]
  /// - Clears references to element and component
  ///
  /// ## Important
  /// Always call `super.unmount()` in overrides.
  @override
  void unmount() {
    // First remove the child element
    if (_childElement != null) {
      updateChild(_childElement, null, _childElement!.slot);
      _childElement = null;
    }

    super.unmount();
    _cm
      ..dispose()
      ..element = null
      ..componentInstance = null;
  }

  /// Adds this element to the tree as a child of the given parent.
  ///
  /// Called when a newly created element is added to the tree for the first time.
  /// This method initializes the ComponentModel and performs the first build.
  ///
  /// ## Parameters
  /// - [parent] — the parent element (null for root)
  /// - [newSlot] — the slot that defines where this element fits in the parent
  ///
  /// ## Lifecycle
  /// 1. Calls `super.mount()` to initialize the element
  /// 2. Creates ComponentModel via factory (only once)
  /// 3. Initializes ComponentModel via [ComponentModel.initComponentModel()]
  /// 4. Calls [ComponentModel.didChangeDependencies()]
  /// 5. Performs first build via [_firstBuild()]
  ///
  /// ## Important
  /// Always call `super.mount()` in overrides.
  @override
  void mount(Element? parent, ElementSlot newSlot) {
    super.mount(parent, newSlot);

    if (!_isInitialized) {
      _cm = component.cmFactory(this);
      _cm
        ..element = this
        ..componentInstance = component
        ..initComponentModel()
        ..didChangeDependencies();

      _isInitialized = true;
    }

    // After initialization, build the child element
    _firstBuild();
  }

  /// Performs the first build after mount.
  ///
  /// Creates the child element from the [Component] returned by [build()].
  /// This method is called only once during the element's lifetime.
  ///
  /// ## Important
  /// This method asserts that [_isInitialized] is true.
  void _firstBuild() {
    assert(_isInitialized);
    _childElement = updateChild(_childElement, build(), ElementSlot(0, null));
  }

  /// Determines whether the element should rebuild when the component changes.
  ///
  /// ## Returns
  /// - `true` — always rebuild, as the ComponentModel may have changed
  ///
  /// ## Important
  /// This method exists only as a performance optimization and gives no
  /// guarantees about when the component is rebuilt. Keep the implementation
  /// as efficient as possible.
  @override
  bool shouldRebuild(covariant Component newComponent) {
    // Always rebuild as ComponentModel may have changed
    return true;
  }

  /// Causes the component to update itself.
  ///
  /// Called by the [BuildOwner] when rebuilding. This method updates the child
  /// element with the new [Component] from [build()].
  ///
  /// ## Error handling
  /// If an error occurs during rebuild, it is rethrown with the stack trace.
  ///
  /// ## Important
  /// This method is called automatically by the framework. Do not call it directly.
  @override
  void performRebuild() {
    try {
      // Update the child element with the new Component from build()
      _childElement = updateChild(_childElement, build(), ElementSlot(0, null));
    } catch (e, stack) {
      Error.throwWithStackTrace(e, stack);
    }
  }

  /// Calls the argument for each child element.
  ///
  /// This method is used by the framework to traverse the element tree.
  /// It visits the [_childElement] if it exists.
  ///
  /// ## Parameters
  /// - [visitor] — the function to call for each child
  ///
  /// ## Important
  /// There is no guaranteed order in which children will be visited.
  @override
  void visitChildren(ElementVisitor visitor) {
    if (_childElement != null) {
      visitor(_childElement!);
    }
  }

  /// Whether the element is currently building.
  ///
  /// Used for debugging and assertions. Returns `false` as this element
  /// does not track build state separately.
  ///
  /// ## Returns
  /// - `false` — always false for this implementation
  @override
  bool get debugDoingBuild => false;
}
