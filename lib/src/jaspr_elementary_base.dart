/// Base export of all internal modules.
///
/// This file is used for internal code organization within the package.
/// It consolidates all the core components of the jaspr_elementary package
/// into a single library for easier internal management.
///
/// ## Purpose
///
/// This library serves as an internal aggregation point for all package
/// exports. It is not intended to be imported directly by package users.
/// Instead, users should import the public API through `jaspr_elementary.dart`.
///
/// ## Architecture
///
/// The package is organized into the following modules:
///
/// | Module | Description |
/// |--------|-------------|
/// | `component/` | Core components for MVVM architecture |
/// | `factory/` | Factory function types for ViewModel creation |
/// | `model/` | Business logic base classes |
/// | `utils/` | Utility classes (error handling, etc.) |
/// | `view_model/` | ViewModel base classes and interfaces |
///
/// ## Internal vs Public API
///
/// This file exports all internal modules for convenience within the package.
/// The public API is re-exported through `jaspr_elementary.dart`, which is
/// the recommended import path for users of the package.
///
/// ### Internal import (within package)
/// ```dart
/// import 'package:jaspr_elementary/src/jaspr_elementary_base.dart';
/// ```
///
/// ### Public import (for package users)
/// ```dart
/// import 'package:jaspr_elementary/jaspr_elementary.dart';
/// ```
///
/// ## Exported modules
///
/// ### Component layer
/// - [ElementaryComponent] — Base component for MVVM architecture
/// - [ElementaryElement] — Element that manages ViewModel lifecycle
///
/// ### Factory layer
/// - [ViewModelFactory] — Factory function type for creating ViewModels
///
/// ### Model layer
/// - [ElementaryModel] — Base class for business logic
///
/// ### Utils layer
/// - [ErrorHandler] — Interface for centralized error handling
///
/// ### ViewModel layer
/// - [IViewModel] — Base marker interface for all ViewModels
/// - [ViewModel] — Base class for presentation logic
///
/// ## Important notes
///
/// - This file is part of the internal package structure
/// - Changes to this file should be carefully considered as they affect
///   all internal imports
/// - The public API in `jaspr_elementary.dart` should remain stable
///   even if internal organization changes
///
/// See also:
///
///  * `jaspr_elementary.dart`, for the public API export file
///  * [ElementaryComponent], for the base component class
///  * [ViewModel], for the base ViewModel class
///  * [ElementaryModel], for the base business logic class
library;

export 'component/elementary_component.dart';
export 'component/elementary_element.dart';
export 'factory/view_model_factory.dart';
export 'model/elementary_model.dart';
export 'utils/error_handler.dart';
export 'view_model/i_view_model.dart';
export 'view_model/view_model.dart';
