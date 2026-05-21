import 'package:hive_flutter/hive_flutter.dart';
import 'package:kickin/core/storage/hive/src/app_hive.dart';
import 'package:kickin/core/storage/hive/src/secure_hive.dart';

/// Top-level helper to initialize and access app and secure Hive boxes.
///
/// Use `KickinHive.on.initialize()` early in your app start-up to ensure
/// the underlying Hive boxes are ready for use.
class KHive<T> {
  static final on = KHive._();
  KHive._();
  static bool _hiveInitialized = false;

  /// Make sure to initialize [KHive] before using
  final app = KAppHive<T>();

  /// Make sure to initialize [KHive] before using
  final secure = KSecureHive<T>();

  /// If box was already opened, it does nothing. else, it opens the boxes marked as true
  Future<void> initialize({bool initApp = true, bool initSecure = true}) async {
    if (!_hiveInitialized) {
      await Hive.initFlutter();
      _hiveInitialized = true;
    }
    if (initApp && !app.isInitialized) await app.initialize();
    if (initSecure && !secure.isInitialized) await secure.initialize();
  }
}
