import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:kickin/core/network/rest/src/network_logger.dart';
import 'package:kickin/core/storage/hive/default_hive_box_names.dart';

import 'package:kickin/core/storage/hive/kickin_hive.dart';
import 'package:kickin/core/storage/hive/src/hive.dart';
import 'package:kickin/core/utilities/result.dart';

export 'package:dio/dio.dart' show CancelToken, Options, FileAccessMode;

part 'src/api_monitor_mixin.dart';

part 'src/rest_request.dart';
part 'src/api_response.dart';

part 'models/log_options.dart';

part 'rest_api.dart';

/// =================================================
/// ApiBase
/// =================================================
/// Base class for the top-level API container in this package.
///
/// Extend this class once per app-level API root and let that object own the
/// concrete API clients for the app, such as `ChatsApi` and `UsersApi`.
/// Shared configuration such as API keys, monitoring, and cache setup lives
/// here.
///
/// Create the child API objects after the `ApiBase` instance exists, either in
/// the constructor body or through a lazy getter / `late final` field.
///
/// Example:
/// ```dart
/// class MainApi extends kickin.ApiBase {
///   static final on = MainApi._();
///   MainApi._();
///
///   late final ChatsApi chats = ChatsApi(this);
///   late final UsersApi users = UsersApi(this);
/// }
/// ```
///
/// Use a single shared instance for each API root to avoid cache or state
/// conflicts between clients.

/// Use only one instance of this class per API root to avoid cache conflicts. For example, if you have a `MainApi` class that extends `KApiBase`, create a single instance of `MainApi` and use it throughout your app.
abstract class KRestApiBase {
  KRestApiBase();

  /// =================================================
  /// Private members
  /// =================================================

  /// Cache
  final _cacheMap = <String, dynamic>{};
  final _pendingWrites = Queue<String>(); // Keys waiting to be flushed
  Timer? _flushTimer;
  static const _flushDelay = Duration(milliseconds: 300);

  AppHive? _syncHive; // Set when syncCacheToStorage is enabled
  bool _syncEnabled = false;

  CacheType? _getCache<CacheType>(String key) => _cacheMap[key] as CacheType?;

  void _setCache<CacheType>(String key, CacheType value) {
    _cacheMap[key] = value;
    if (_syncEnabled) _schedulePersist(key);
  }

  void _removeCache(String id) {
    _cacheMap.remove(id);
    if (_syncEnabled) _schedulePersist(id);
  }

  void _schedulePersist(String key) {
    if (!_pendingWrites.contains(key)) {
      _pendingWrites.addLast(key);
    }
    _flushTimer?.cancel();
    _flushTimer = Timer(_flushDelay, _flushPendingWrites);
  }

  Future<void> _flushPendingWrites() async {
    if (_pendingWrites.isEmpty || _syncHive == null) return;
    final hive = _syncHive!;
    if (!hive.isInitialized) await hive.initialize();

    final keysToFlush = List<String>.from(_pendingWrites);
    _pendingWrites.clear();

    final kApiBaseKeysKey = "${runtimeType}_keys";

    for (final key in keysToFlush) {
      final value = _cacheMap[key];
      if (value != null) {
        await hive.setData(key: key, value: value);
      } else {
        await hive.deleteData(key: key);
      }
    }

    // Update the stored key index
    final liveKeys = _cacheMap.keys.toList();
    await hive.setData(key: kApiBaseKeysKey, value: liveKeys);
  }

  bool _enabledMonitoring = kDebugMode;
  String _baseUrl = '';

  Dio _primaryDio = Dio();
  Dio _externalDio = Dio();

  LogOptions _logOptions = const LogOptions();

  /// [withApiKeys]: A map of API keys to be registered. The keys should implement the [ApiKeyEnum] interface. Remember to register keys for all APIs you intend to use in the system.
  ///
  /// [monitorActivities]: If true, enables monitoring of API activities (only in debug mode).
  /// Don't use syncCacheToStorage yet, not yet implemented!
  Future<void> intialize({
    /// It prefixes all requests with the provided baseUrl. If not provided or is empty, nothing get's prefixed
    String? baseUrl,
    bool monitorActivities = kDebugMode,
    String cacheBoxName = kApiCacheBoxName,
    bool syncCacheToStorage = false,
    LogOptions logOptions = const LogOptions.normal(),
  }) async {
    _enabledMonitoring = monitorActivities;
    _baseUrl = baseUrl ?? '';
    if (_enabledMonitoring) {
      // Start monitoring API activities
    }
    if (!Hive.isBoxOpen(cacheBoxName)) {
      // Setup the cache box
    }
    if (syncCacheToStorage) {
      if (!kickinCacheHive.isInitialized) await kickinCacheHive.initialize();
      _syncHive = kickinCacheHive;
      _syncEnabled = true;
      await _syncCacheFromStorage(kickinCacheHive);
    }
    _logOptions = logOptions;
  }

  /// Replaces the primary Dio instance used by requests that opt into it.
  void setPrimaryDio(Dio dio) => _primaryDio = dio;

  /// Replaces the external Dio instance used by requests that opt out of the primary client.
  void setExternal(Dio dio) => _externalDio = dio;

  Future<void> _syncCacheFromStorage(AppHive hive) async {
    if (!hive.isInitialized) await hive.initialize();
    final kApiBaseKeysKey = "${runtimeType}_keys";
    final storedKeys = hive.getData(key: kApiBaseKeysKey) as List<String>? ?? <String>[];
    for (final key in storedKeys) {
      final value = await hive.getData(key: key);
      if (value != null) _cacheMap[key] = value;
    }
  }
}
