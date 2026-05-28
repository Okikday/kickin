# 🦵 Kickin (#experimental)

Kickin is a modern modular toolkit designed to turbocharge your Flutter development and eliminate boilerplate. It provides curated utilities, elegant extensions, and standardized architectures for common tasks like networking, state management, and storage.

Zero lock-in. While Kickin provides opinionated wrappers for popular tools, it is designed to be **universally adoptable** and highly extensible. You can use it piece-by-part (select the core extensions), use the network module independently, or fully embrace the architecture.

---

## 🎯 Modules at a Glance

### 🌐 Network
A unified layer for all remote communication, adaptable to different protocols.

Check [kickin_network](https://pub.dev/packages/kickin_network)

### 💾 Storage
A unified abstraction for local persistent storage, architected to support multiple drivers smoothly.

Check [kickin_storage](https://pub.dev/packages/kickin_storage)

### 🧠 State Management
Streamlined, ergonomic, and boilerplate-free APIs to bind your favorite state management solutions to the UI.

* **Riverpod**
  Effortless provider binding without needing a verbose `ConsumerWidget` wrapper.
  * **Key Classes:** `KAbsorber`, `KAbsorbRead`, `KAbsorbWatch`, `KWatchNotifier`, `KCachedNotifier`
  * **Usage:**
    ```dart
    KAbsorber.watch(
      userProvider,
      builder: (ref, user, child) {
         return Text(user.name);
      }
    )

    final user = userProvider.read(ref);
    ```

### ⚙️ Utilities
Essential and predictable helpers for async operations and heavy background tasks.

* **Concurrency & Operations**
  Tools to perform safe operations and background work.
  * **Key Classes:** `KResult` (safe operations without try-catch), `KIsolate` (background work), `KLogger`
  * **Usage:**
    ```dart
    final result = await KResult.tryRunAsync(() => fetchComplexData());
    
    if (result.isSuccess) {
      print(result.data);
    } else {
      showError(result.message);
    }
    ```

### 🧩 Extensions & Mixins
Banish verbose code with intuitive extensions on built-in types. Plus, reusable mixins to inject intelligence into Widgets and Notifiers.

* **Core Extensions**
  * **Key Classes:** Context extensions, `Duration` extensions, `ProviderWarmupMixin`, `ScrollOffsetNotifierMixin`
  * **Usage:**
    ```dart
    // Elegant structural spacing
    24.toVBox, // No more SizedBox(height: 24)
    16.toHBox, // No more SizedBox(width: 16)

    // Quick context helpers
    final isDark = context.isDarkMode;
    final screenWidth = context.deviceWidth;
    final topPadding = context.topPadding;
    ```

### 🎨 Widgets & Motion
A collection of smart, adaptable UI components and pre-defined motion tokens for fluid experiences.

* **Layout & Components**
  * **Key Classes:** `KScaffold`, `KAnimatedSizing`, `KScaleGestureWrapper`, `KSmoothListView`, `KAdaptiveImage`, `KSpacing`, `KCurves`
  * **Usage:**
    ```dart
    KScaffold(
      title: 'Home',
      body: KSmoothListView(
        children: [
          KTopPadding.sliver(),
          KAdaptiveImage(path: FilePath(path: localPath, url:"https://..."), preferLocal: true),
          KBottomPadding.sliver(),
        ],
      ),
    );

    ```

---

## 📦 Installation

Add the package to your app dependencies:

```yaml
dependencies:
  kickin: 0.0.1-dev.29
```

Then import the package root API where needed:

```dart
import 'package:kickin/kickin.dart';
```

## 🚀 Vision
Kickin is designed to act as **parts of a broader whole**. You can adopt the Network module and ignore the Storage module; use the Extensions but skip the Widgets. It's built for rapid prototyping while being sufficiently robust for large-scale production applications. Start coding faster, with absolute confidence.