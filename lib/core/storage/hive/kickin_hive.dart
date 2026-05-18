import 'package:hive_flutter/hive_flutter.dart';
import 'package:kickin/core/storage/hive/src/app_hive.dart';
import 'package:kickin/core/storage/hive/src/secure_hive.dart';

class KickinHive<T> {
  static final on = KickinHive._();
  KickinHive._();
  static bool _hiveInitialized = false;

  /// Make sure to initialize [KickinHive] before using
  final app = AppHive<T>();

  /// Make sure to initialize [KickinHive] before using
  final secure = SecureHive<T>();

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
