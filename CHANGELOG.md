## 0.0.1-dev.12
- Improved error handling in the KRestRequest classes

## 0.0.1-dev.11
- Minimal changes to generic types on some classes

## 0.0.1-dev.10
- Improvements to the copyWith access method on the _KRestRequest classes

## 0.0.1-dev.9
- Centralized shared request fields in `KRestRequest` and kept concrete request wrappers focused on method-specific behavior.
- Added PUT, PATCH, DELETE, and download request wrappers to the API surface.
- Expanded inline API documentation for the request helpers and updated the package exports.

## 0.0.1-dev.8
- Updated example app

## 0.0.1-dev.7
- Updated documentations

## 0.0.1-dev.6
- Refactored the public API for consistency by prefixing core widgets and utilities with `K`.
- Renamed isolate helpers to `KIsolate`, `KIsolateContinuous`, `KIsolateAccess`, and `KIsolateException`.
- Added `KApiResponse` for wrapping and transforming API responses.
- Added `KScaffold` for configurable app shells with built-in app bar and footer support.
- Added shared motion and spacing tokens with `KCurves` and `KSpacing`.
- Updated networking support to use `dio`.

## 0.0.1-dev.5
- Refactored the API structure by renaming and reorganizing classes and removing the unused interface.
- Improved API documentation and internal cleanup, including removal of the unused cache mixin.
- Updated the package surface and tests to match the new API layout.

## 0.0.1-dev.4
- Improved exporting from library
## 0.0.1-dev.3
- Update docs
## 0.0.1-dev.2
- Introduced a some sets of utilities, extensions, and widgets to eliminate boilerplate.
- **State Management**: Added `Absorb` helpers, standard `Notifiers`, and `KCachedNotifier` for Riverpod and Hive integration.
- **Storage**: Added `KickinHive` singleton to seamlessly manage standard and secure local boxes.
- **Async & Background Tasks**: Added `Result` for safe async handling and `SmartIsolate` for heavy workloads with progress updates.
- **Widgets**: Added `ScaleGestureWrapper`, `AnimatedSizing`, `AdaptiveImage`, and `AppText`.
- **Layouts**: Added `SmoothListView` and `SmoothCustomScrollView` for Mac/Windows-like momentum scrolling, plus convenient `TopPadding` / `BottomPadding` widgets.
- **Extensions**: Provided useful extensions on `BuildContext`, `num`, `String`, `Color`, and `Provider` for faster, cleaner layout and data parsing.
- Overhauled and abstracted the `ApiBase` and API key configuration structures.

## 0.0.0-dev.1
 Initializing project...