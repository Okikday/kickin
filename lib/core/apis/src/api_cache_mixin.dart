part of '../api_base.dart';

mixin _ApiCache {
  T? getCache<T>(String key) => _cacheMap[key] as T?;
  void setCache(String key, dynamic value) => _cacheMap[key] = value;
}
