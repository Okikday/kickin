import 'dart:async';

import 'package:flutter/foundation.dart';

part 'src/api_monitoring_mixin.dart';
part 'src/api_interface.dart';

/// Base class for API keys. Each API key should implement this interface to be used in the API system.
/// Example usage:
/// ```dart
/// enum MyApiKeys implements ApiKeyEnum {
/// googleMaps,
/// }
/// ```
abstract class ApiKeyEnum implements Enum {}

extension ApiKeyEnumExtension on ApiKeyEnum {
  String get key => _apiKeys.containsKey(this) ? _apiKeys[this]! : throw Exception('API key not found for $this');
}

/// =================================================
/// Private members
/// =================================================
final _apiKeys = <ApiKeyEnum, String>{};
bool _enabledMonitoring = kDebugMode;

/// =================================================
/// Classes
/// =================================================
abstract class ApiBase {
  const ApiBase();

  /// [withApiKeys]: A map of API keys to be registered. The keys should implement the [ApiKeyEnum] interface. Remember to register keys for all APIs you intend to use in the system.
  ///
  /// [monitorActivities]: If true, enables monitoring of API activities (only in debug mode).
  Future<void> intialize({Map<ApiKeyEnum, String>? withApiKeys, bool monitorActivities = kDebugMode}) async {
    _enabledMonitoring = monitorActivities;
    if (withApiKeys != null && withApiKeys.isNotEmpty) {
      _apiKeys.addAll(withApiKeys);
    }
    if (_enabledMonitoring) {
      // Start monitoring API activities
    }
  }

  /// Retrieves the API key associated with the given [apiKeyId]. Throws an exception if the API key is not found.
}
