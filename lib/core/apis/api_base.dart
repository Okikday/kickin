import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kickin/core/storage/hive/default_hive_box_names.dart';
import 'package:kickin/core/apis/src/api_response.dart';

export 'package:dio/dio.dart' show CancelToken, Options, FileAccessMode;

part 'src/api_monitor_mixin.dart';

part 'src/rest_request.dart';

part 'api.dart';

typedef Any = dynamic;

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

final _apiKeys = <Enum, String>{};

/// Use only one instance of this class per API root to avoid cache conflicts. For example, if you have a `MainApi` class that extends `KApiBase`, create a single instance of `MainApi` and use it throughout your app.
abstract class KApiBase {
  KApiBase();
  static int _increment = -1;
  static int get _incrementId => _increment++;

  /// =================================================
  /// Private members
  /// =================================================

  /// Cache
  final _cacheMap = <int, Any>{};
  CacheType? _getCache<CacheType>(int key) => _cacheMap[key] as CacheType?;
  void _setCache<CacheType>(int key, CacheType value) => _cacheMap[key] = value;

  bool _enabledMonitoring = kDebugMode;
  String _baseUrl = '';

  /// [withApiKeys]: A map of API keys to be registered. The keys should implement the [ApiKeyEnum] interface. Remember to register keys for all APIs you intend to use in the system.
  ///
  /// [monitorActivities]: If true, enables monitoring of API activities (only in debug mode).
  /// Don't use syncCacheToStorage yet, not yet implemented!
  Future<void> intialize({
    required String baseUrl,
    Map<Enum, String>? withApiKeys,
    bool monitorActivities = kDebugMode,
    String cacheBoxName = kApiCacheBoxName,
    bool syncCacheToStorage = false,
  }) async {
    _enabledMonitoring = monitorActivities;
    _baseUrl = baseUrl;
    if (withApiKeys != null && withApiKeys.isNotEmpty) {
      _apiKeys.addAll(withApiKeys);
    }
    if (_enabledMonitoring) {
      // Start monitoring API activities
    }
    if (!Hive.isBoxOpen(cacheBoxName)) {
      // Setup the cache box
    }
    if (syncCacheToStorage) {
      throw UnimplementedError('Cache synchronization to storage is not implemented yet.');
    }
  }

  /// Replaces the primary Dio instance used by requests that opt into it.
  void setPrimaryDio(Dio dio) => _primary = dio;

  /// Replaces the external Dio instance used by requests that opt out of the primary client.
  void setExternal(Dio dio) => _external = dio;
}
