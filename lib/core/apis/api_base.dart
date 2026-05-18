import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kickin/core/storage/hive/default_hive_box_names.dart';

part 'src/api_monitor_mixin.dart';
part 'src/api_cache_mixin.dart';
part 'src/api_key_enum.dart';

part 'api_interface.dart';

/// =================================================
/// Private members
/// =================================================
final _apiKeys = <ApiKeyEnum, String>{};
final Map<String, dynamic> _cacheMap = {};
bool _enabledMonitoring = kDebugMode;

/// =================================================
/// ApiBase
/// =================================================
/// Base class for API implementations in this package.
///
/// Provides shared initialization for API keys, optional activity monitoring,
/// and cache setup. Extend this to implement concrete APIs consumed by the app.
abstract class ApiBase {
  const ApiBase();

  /// [withApiKeys]: A map of API keys to be registered. The keys should implement the [ApiKeyEnum] interface. Remember to register keys for all APIs you intend to use in the system.
  ///
  /// [monitorActivities]: If true, enables monitoring of API activities (only in debug mode).
  Future<void> intialize({
    Map<ApiKeyEnum, String>? withApiKeys,
    bool monitorActivities = kDebugMode,
    String cacheBoxName = defaultApiCacheBoxName,
  }) async {
    _enabledMonitoring = monitorActivities;
    if (withApiKeys != null && withApiKeys.isNotEmpty) {
      _apiKeys.addAll(withApiKeys);
    }
    if (_enabledMonitoring) {
      // Start monitoring API activities
    }
    if (!Hive.isBoxOpen(cacheBoxName)) {
      // Setup the cache box
    }
  }
}
