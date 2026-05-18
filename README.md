# Kickin — Practical Flutter utilities and widgets (In Progress)

Kickin is a comprehensive toolkit designed to strip away boilerplate and simplify common, repetitive tasks in Flutter development. It packs robust utility classes, powerful extensions, and opinionated wrappers around popular community tools (like state management and persistency) to give you better developer ergonomics and predictable behaviour right out of the box.

Features
- Boilerplate-free architecture: Helpers and mixins that tackle daily repetitive code
- Wrappers for popular tools: Ergonomic APIs for state management (e.g. Riverpod) and storage libraries (e.g. Hive)
- Result wrapper for safe and predictable async operations
- Smart isolate helpers for background work with progress reporting
- Handy extensions for `BuildContext`, `num`, `String`, providers and durations
- Useful widgets: `AnimatedSizing`, `ScaleGestureWrapper`, `SmoothListView`, `AdaptiveImage`, and more

Quick install

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  kickin: 0.0.1-dev.2
```

Then import the package root API where needed:

```dart
import 'package:kickin/kickin.dart';
```

Getting started

Initialize the persistent storage driver (e.g. Hive) if you intend to use the built-in storage features:

```dart
await KickinHive.on.initialize();
KickinHive.on.app.setData(key: key, value: value);
```

API summary

The library re-exports a compact public API from `lib/kickin.dart`.

- **core/apis** (`lib/core/apis/api_base.dart`)
  - `ApiBase` — base initializer for API systems and API key registration.
  - `Api` — lightweight API interface mixing in caching and monitoring.
  - `ApiKeyEnum` + `ApiKeyEnumExtension.key` — register and read API keys.

- **core/base** (`lib/core/base/base.dart`)
  - Extensions: `NumDurationExtension`, `WidgetExtension`, `StringExtension`, `ColorsExtension`, `ExtensionOnContext`, `ProviderExtension`, `AsyncProviderExtension`, `RefExtensions`, `WidgetRefExtensions`, `NotifierX`, `AsyncNotifierX`, `ExtensionOnDuration` — handy getters and helpers for common patterns (durations, spacing, context, provider read/watch, etc.).
  - Mixins: `IsScrolledNotifierMixin`, `PageControllerMixin`, `ScrollOffsetNotifierMixin`, `ProviderWarmupMixin` — reusable stateful behaviours.

- **core/state_management** (`lib/core/state_management/riverpod/riverpod.dart`)
  - `Absorb`, `AbsorbWatch`, `AbsorbRead` — concise consumer helpers to reduce UI boilerplate.
  - Notifiers: Pre-built standard notifiers (`IntNotifier`, `StringNotifier`, `BoolNotifier`...) and `PersistentNotifier` for synced offline storage.

- **core/storage** (`lib/core/storage/hive/kickin_hive.dart`)
  - `KickinHive<T>` — unified wrapper to effortlessly manage application and secure storage boxes.

- **core/utilities**
  - `Result<T>` (`lib/core/utilities/result.dart`) — lightweight success/loading/error wrapper with helpers `tryRun`, `tryRunAsync`, `doNext`, `then`.
  - `SmartIsolate`, `SmartIsolateContinuous`, `SmartIsolateAccess`, `SmartIsolateException`, and `WorkPriority` (`lib/core/utilities/smart_isolate.dart`) — easy-to-use isolate helpers with progress, priority queues and persistent worker isolates.

- **widgets**
  - `AnimatedSizing` — small AnimatedSize wrapper with `fast`, `normal`, `slow` factories.
  - `ScaleGestureWrapper` — clickable widget with scale animation and configurable callbacks.
  - `TopPadding`, `BottomPadding` — quick helpers that respect safe areas and keyboard inset.
  - `AppText` — compact text widget applying theme defaults.
  - `SmoothListView` / `SmoothCustomScrollView` — desktop-optimized smooth scrolling list and custom scroll view (with `SmoothScrollMode`, `ScrollIntensity` and `SmoothScrollPhysics`).
  - `AdaptiveImage` / `ImageFromMemory` and exported `FilePath` model — show local or network images with graceful fallback and caching.

Examples

Extensions & context helpers

```dart
// Elegant spacing in rows/columns
Widget build(BuildContext c) => Column(
  children: [
    const Text('Top'),
    24.toVBox, // No more verbose SizedBox(height: 24)
    const Text('Bottom'),
  ],
);

// Access media queries and theme securely with zero boilerplate
final isDark = context.isDarkMode;
final screenWidth = context.deviceWidth;
final topPadding = context.topPadding;
```

State Management & Offline Storage

```dart
// 1. A Notifier that auto-magically persists to local storage (Hive, etc.)
class ThemeModeNotifier extends PersistentNotifier<String, ThemeMode> {
  ThemeModeNotifier() : super(
    'theme_mode_key', 
    ThemeMode.system,
    encode: (mode) => mode.name,
    decode: (raw) => ThemeMode.values.byName(raw ?? 'system'),
  );
}

// 2. Pre-built standard notifiers to avoid repetitive boilerplate (riverpod 3.0+)
final counterProvider = NotifierProvider<IntNotifier, int>(() => IntNotifier(0));
final userProvider = NotifierProvider<SomeNotifier<User?>, User?>(() => SomeNotifier(null));

// Update values easily:
// ref.read(counterProvider.notifier).set(5);
// ref.read(counterProvider.notifier).update((state) => state + 1);

// 3. Surgical rebuilds using Absorb without ConsumerWidget boilerplate
Widget build(BuildContext context) {
  return Absorb.watch(
    themeProvider,
    builder: (ref, theme, _) => MaterialApp(
      themeMode: theme, // Now responsive to changes
      home: const Home(),
    ),
  );
}
```

Safe Async Operations (Result)

Avoid endless `try-catch` blocks and effectively manage data/loading/error states.

```dart
Future<Result<User>> fetchUser(String id) async {
  return Result.tryRunAsync(() async {
    final response = await api.getUser(id);
    return User.fromJson(response);
  }).then((user) async {
    await cache.save(user); // Chained safely. Skipped if error occurred above.
    return user;
  });
}
```

Heavy Background Workers (Smart Isolate)

Run intense workloads safely away from the main thread without stuttering the UI. Send progress updates back to the UI in real-time.

```dart
// Execute right away with progress reporting 
final compressedBytes = await SmartIsolate.run<Uint8List, double, Uint8List>(
  (imageBytes, emit) async {
    emit(0.2); // Notify UI: 20% done
    final processed = await heavyImageCompression(imageBytes);
    emit(1.0); // Notify UI: 100% done
    return processed;
  },
  rawImageBytes,
  onProgress: (percent) => print('Compressing: ${percent * 100}%'),
);

// Or create a continuous background worker with a priority queue
final imageWorker = await SmartIsolateContinuous.spawn<ImageTask, ImageResult>(
  (register) async {
    final decoder = await setupHeavyModel(); // Run once initialization
    register((task, respond) => respond(decoder.process(task)));
  },
);

imageWorker.execute(task, priority: WorkPriority.high);
```

Widgets & UI interactions

```dart
// Bouncy, squishy, and hyper-interactive buttons out of the box
ScaleGestureWrapper(
  onTapUp: (details) => navigateToDetails(),
  scaleBetween: (1.0, 0.92),
  child: AnimatedSizing.fast(
    child: Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppText('Squish me!', fontWeight: FontWeight.bold),
      ),
    ),
  ),
);

// Mac/Windows-like buttery-smooth momentum scrolling on desktop platforms.
// Automatically falls back to native physics on mobile!
SmoothListView.builder(
  mode: SmoothScrollMode.auto,
  intensity: ScrollIntensity.slow,
  itemCount: 100,
  itemBuilder: (context, index) => ListTile(
    leading: AdaptiveImage(
      path: FilePath(url: 'https://...', local: 'assets/fallback.png'),
      fallbackWidget: const Icon(Icons.error),
    ),
    title: Text('Item $index'),
  ),
);
```

Documentation & examples

This README highlights the root-level API. For implementation details and more examples, see the source files in:
- [lib/kickin.dart](lib/kickin.dart#L1)
- [lib/core/base](lib/core/base)
- [lib/core/state_management/riverpod](lib/core/state_management/riverpod)

Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

License

This project is available under the terms of the LICENSE file.

Maintainers

<a href="https://github.com/okikday">
  <img src="https://github.com/okikday.png" width="50" height="50" style="border-radius: 50%;" alt="okikday" />
</a>
<br/>
**[okikday](https://github.com/okikday)**
