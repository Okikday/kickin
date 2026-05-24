# 🦵 Kickin (#experimental)

Kickin is a modern modular toolkit designed to turbocharge your Flutter development and eliminate boilerplate. It provides curated utilities, elegant extensions, and standardized architectures for common tasks like networking, state management, and storage.

Zero lock-in. While Kickin provides opinionated wrappers for popular tools (like Riverpod or Hive), it is designed to be **universally adoptable** and highly extensible. You can use it piece-by-part—select the core extensions, use the network module independently, or fully embrace the architecture.

---

## 🎯 Modules at a Glance

### 🌐 Network
A unified layer for all remote communication, adaptable to different protocols.

* **REST APIs**
  A robust and extensible wrapper over Dio to handle HTTP requests gracefully with structured error handling, caching, logging, and decoding.
  * **Key Classes:** `KRestApiBase`, `KRestApi`, `KRestRequest`, `KResponse`
  * **Usage:**
    ```dart
    class MyApi extends KRestApiBase {
      static final kick = MyApi._();
      MyApi._();

      // make sure to initialize in main()
      // e.g. MyApi.kick.initialize(baseUrl: 'https://api.myapp.com', logOptions: LogOptions.debugAll());
      
      late final users = UsersApi(this);
    }
    
    class UsersApi extends KRestApi<Map<String, dynamic>> {
      UsersApi(super.parent);

      // You can also choose to cache your data as they come in
      

      /// You can also make this a getter instead of late final incase you need to pass a data(body)
      late final _getUser = KGetRequest(
        this, 
        path: '/user', 
        resolve: (r) async => r.copyWith(headers: await loadAuthHeaders()),
        decoder: (data, _) => User.fromJson(data),
      );

      Future getUser () => _getUser.get();
    }

    // Call securely and retrieve the decoded data
    final user = await MyApi.kick.users.getUser(); 
    ```

### 💾 Storage
A unified abstraction for local persistent storage, architected to support multiple drivers smoothly.

* **Hive**
  A fast key-value storage implementation powered by Hive. Includes app-level, secure, and lazy options.
  * **Key Classes:** `KHive`, `KSecureHive`, `KLazyHive`
  * **Usage:**
    ```dart
    // Initialize at app startup
    enum KHiveKeys{theme}
    await KHive.on.initialize(initApp: true);

    // Save and retrieve anywhere safely
    await KHive.on.app.setData(key: KHiveKeys.theme.name, value: 'dark');
    final theme = KHive.on.app.getData(key: 'theme'); // or KHiveKeys.theme.name
    ```

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
  kickin: 0.0.1-dev.22
```

Then import the package root API where needed:

```dart
import 'package:kickin/kickin.dart';
```

## 🚀 Vision
Kickin is designed to act as **parts of a broader whole**. You can adopt the Network module and ignore the Storage module; use the Extensions but skip the Widgets. It's built for rapid prototyping while being sufficiently robust for large-scale production applications. Start coding faster, with absolute confidence.