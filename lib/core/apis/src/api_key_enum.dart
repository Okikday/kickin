part of '../api_base.dart';

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
