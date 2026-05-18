import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickin/core/storage/hive/default_hive_box_names.dart';
import 'package:kickin/core/storage/hive/src/app_hive.dart';
import 'package:kickin/core/utilities/result.dart';

export 'package:flutter_riverpod/flutter_riverpod.dart';

//=============================================
// BASE NOTIFIER
//=============================================
abstract class _BaseNotifier<T> extends Notifier<T> {
  final T _defaultKey;
  _BaseNotifier(this._defaultKey);
  @override
  T build() => _defaultKey;

  void update(T Function(T) cb) {
    final next = cb(state);
    if (next != state) state = next;
  }

  void set(T value) => state = value;
}

//=============================================
// PRIMITIVE TYPE NOTIFIERS
//=============================================
class IntNotifier extends _BaseNotifier<int> {
  IntNotifier([super._defaultKey = 0]);
}

class DoubleNotifier extends _BaseNotifier<double> {
  DoubleNotifier([super._defaultKey = 0.0]);
}

class StringNotifier extends _BaseNotifier<String> {
  StringNotifier([super._defaultKey = '']);
}

class BoolNotifier extends _BaseNotifier<bool> {
  BoolNotifier([super._defaultKey = false]);
  void toggle() => state = !state;
}

class SomeNotifier<T> extends _BaseNotifier<T> {
  SomeNotifier(super._defaultKey);
}

//=============================================
// ASYNC* BASE NOTIFIER
//=============================================
class WatchNotifier<T> extends StreamNotifier<T> {
  final Stream<T> Function() _streamFactory;
  WatchNotifier(this._streamFactory);
  @override
  Stream<T> build() => _streamFactory();
}

//=============================================
// ASYNC BASE NOTIFIER
//=============================================

abstract class _AsyncBaseNotifier<T> extends AsyncNotifier<T> {
  final T _defaultKey;
  _AsyncBaseNotifier(this._defaultKey);

  @override
  FutureOr<T> build() => _defaultKey;

  void set(T value) => state = AsyncData(value);
}

class SomeAsyncNotifier<T> extends _AsyncBaseNotifier<T> {
  SomeAsyncNotifier(super._defaultKey);
}

// ============================================================================
// PersistentNotifier - With Hive persistence
// ============================================================================

/// [In] is how the data get's stored
/// [Out] is how the data is output
class PersistentNotifier<In, Out> extends AsyncNotifier<Out> {
  static final _hive = AppHive(boxName: defaultRiverpodCacheBoxName);
  final String _key;
  final Out _defaultValue;
  final bool? isUpdateNotifying;
  final FutureOr<Out> Function(In? data)? decode;
  final FutureOr<In> Function(Out raw)? encode;

  String get key => _key;
  Out get defaultValue => _defaultValue;

  Future<void> _writeLock = Future.value();

  PersistentNotifier(this._key, this._defaultValue, {this.isUpdateNotifying, this.decode, this.encode});

  @override
  Future<Out> build() async {
    return (await Result.tryRunAsync<Out>(() async {
              if (!_hive.isInitialized) await _hive.initialize();
              final data = await _hive.getData(key: _key);
              return decode?.call(data) ?? data as Out?;
            }))
            .onError((e, [st]) => Result.error<Out>("Try using decode params to properly decode data from storage"))
            .data ??
        _defaultValue;
  }

  Future<void> set(Out value) async {
    state = AsyncData(value);
    if (!_hive.isInitialized) await _hive.initialize();
    await _scheduleWrite(value);
  }

  Future<void> updateIfNotEqual(Out value) async {
    if (value == state.value) return;
    await set(value);
  }

  Future<void> _scheduleWrite(Out value) async => await Result.tryRunAsync(
    () async => _writeLock = _writeLock.then((_) {
      final encoded = encode?.call(value) ?? value as In;
      return _hive.setData(key: _key, value: encoded);
    }),
  ).onError((e, st) => Result.error("Try using the encode params: $e"));

  @override
  bool updateShouldNotify(AsyncValue<Out> previous, AsyncValue<Out> next) =>
      isUpdateNotifying ?? super.updateShouldNotify(previous, next);
}
