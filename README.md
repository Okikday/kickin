# Kickin (#experimental)

Kickin is a toolkit that removes Flutter boilerplate with utilities, extensions, and opinionated wrappers for common tools (state, storage, etc.), so you can get started quickly by adding the package.

also for users that use [custom_widgets_toolkit](https://pub.dev/packages/custom_widgets_toolkit)
#note documentation doesn't currently capture every feature or usage
Features
- Boilerplate-free architecture: Helpers and mixins that tackle daily repetitive code
- Wrappers for popular tools: Ergonomic APIs for state management (e.g. Riverpod) and storage libraries (e.g. Hive)
- KResult wrapper for safe and predictable async operations
- KIsolate helpers for background work with progress reporting
- Handy extensions for `BuildContext`, `num`, `String`, providers, durations etc
- Useful widgets: `KAnimatedSizing`, `KScaleGestureWrapper`, `KSmoothListView`, `KAdaptiveImage`, `KScaffold`, and more

Quick install

Add the package to your app dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  kickin: 0.0.1-dev.20
```

Then import the package root API where needed:

```dart
import 'package:kickin/kickin.dart';
```

Getting started

Initialize the persistent storage driver (e.g. Hive) if you intend to use the built-in storage features:

```dart
await KHive.on.initialize();
KHive.on.app.setData(key: key, value: value);
```

REST API request example:

```dart
final request = KGetRequest<Map<String, dynamic>, Map<String, dynamic>>(
  '/users/1',
  decode: (data) => data,
);

final user = await request.copyWith(headers: {...}).get();
```

API summary

The public API is intentionally compact and centered around a few high-value areas:

- Core APIs: `ApiBase`, `Api`, `ApiKeyEnum`
- Base helpers: extensions for context, durations, strings, numbers, providers, and widgets; plus reusable mixins
- State management: `KAbsorber`, `KAbsorbRead`, `KAbsorbWatch`, `KWatchNotifier`, and `KCachedNotifier`
- Storage: `KHive`
- Utilities: `KResult`, `KIsolate`, `KIsolateContinuous`, `KIsolateAccess`, `KIsolateException`, `KWorkPriority`
- Motion and layout: `KCurves`, `KSpacing`
- Widgets: `KAnimatedSizing`, `KScaleGestureWrapper`, `KTopPadding`, `KBottomPadding`, `KText`, `KSmoothListView`, `KSmoothCustomScrollView`, `KAdaptiveImage`, `ImageFromMemory`, `KFilePath`, and `KScaffold`

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

// Shared spacing and motion tokens
final gutter = KSpacing.md;
final easing = KCurves.fastInSlowOut;
```

App shell and scaffold

```dart
KScaffold.appBarBuilder = someWidget;
KScaffold(
  title: 'Home',
  footer: Padding(
    padding: EdgeInsets.all(KSpacing.md),
    child: KText('Built with Kickin'),
  ),
  body: Center(
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: KCurves.fastInSlowOut,
      padding: EdgeInsets.all(KSpacing.lg),
      child: KText('Fast, consistent UI shells'),
    ),
  ),
)
```

State Management & Offline Storage

```dart
// 1. A Notifier that auto-magically persists to local storage (Hive, etc.)
class ThemeModeNotifier extends KCachedNotifier<String, ThemeMode> {
  ThemeModeNotifier() : super( 
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

// 3. Surgical rebuilds using KAbsorber without ConsumerWidget boilerplate
Widget build(BuildContext context) {
  return KAbsorber.watch(
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
Future<KResult<User>> fetchUser(String id) async {
  return KResult.tryRunAsync(() async {
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
final compressedBytes = await KIsolate.run<Uint8List, double, Uint8List>(
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
final imageWorker = await KIsolateContinuous.spawn<ImageTask, ImageResult>(
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
KScaleGestureWrapper(
  onTapUp: (details) => navigateToDetails(),
  scaleBetween: (1.0, 0.92),
  child: KAnimatedSizing.fast(
    child: Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: KText('Squish me!', fontWeight: FontWeight.bold),
      ),
    ),
  ),
);

// Mac/Windows-like buttery-smooth momentum scrolling on desktop platforms.
// Automatically falls back to native physics on mobile!
KSmoothListView.builder(
  mode: SmoothScrollMode.auto,
  intensity: ScrollIntensity.slow,
  itemCount: 100,
  itemBuilder: (context, index) => ListTile(
    leading: KAdaptiveImage(
      path: KFilePath(url: 'https://...', local: 'assets/fallback.png'),
      fallbackWidget: const Icon(Icons.error),
    ),
    title: Text('Item $index'),
  ),
);
```

Documentation & examples

Use the root import for the public surface:

```dart
import 'package:kickin/kickin.dart';
```

The examples above cover the main patterns. For implementation details, keep exploring the package API from there.

Changelog

See the changelog for version history.

License

This project is available under the license terms.

Maintainers

<div align="center">
  <div style="display:inline-block;padding:10px;border-radius:999px;background:linear-gradient(135deg, rgba(15,23,42,0.08), rgba(59,130,246,0.18));box-shadow:0 10px 30px rgba(15,23,42,0.12);">
    <a href="https://github.com/okikday" aria-label="okikday on GitHub">
      <img src="https://github.com/okikday.png" width="96" height="96" style="display:block;border-radius:999px;object-fit:cover;border:3px solid rgba(255,255,255,0.85);" alt="okikday" />
    </a>
  </div>
  <div style="margin-top:10px;font-weight:700;">okikday</div>
  <div style="font-size:0.95em;opacity:0.75;">Maintainer</div>
</div>
