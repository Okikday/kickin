import 'dart:developer' as dev;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kickin/core/storage/hive/default_hive_box_names.dart';
import 'package:kickin/core/utilities/result.dart';

/// Simple helper around a Hive box for application-level storage.
///
/// Provides convenience methods for `initialize`, `setData`, `getData`, and
/// watching changes by key.
class AppHive<T> {
  final String boxName;

  Box<T>? _box;

  bool get isInitialized => _box != null;

  AppHive({this.boxName = kAppBoxName});

  Future<void> initialize() async => _box = await Hive.openBox(kAppBoxName);

  Future<void> setData({required String key, required T value}) async {
    if (_box == null || _box!.isOpen == false) {
      dev.log("Hive box was not initialized!");
      return;
    }
    await _box?.put(key, value);
  }

  Future<T?> getData({required String key}) async {
    if (_box == null || _box!.isOpen == false) {
      dev.log("Hive box was not initialized!");
      return null;
    }
    return _box?.get(key);
  }

  Future<void> deleteData({required String key}) async => await Result.tryRunAsync(() async => await _box?.delete(key));

  Stream<void> watchChanges({required String key}) async* {
    yield* _box!.watch(key: key);
  }

  Stream<T?> watchData({required String key}) async* {
    yield (getData(key: key)) as T?;
    yield* _box!.watch(key: key).asyncMap((e) => e.value);
  }

  Future<bool> resetAll(String acknowledge) => Result.tryRunAsync(() async {
    await _box?.clear();
  }).then((_) => true).catchError((_) => false);
}
