part of 'api_base.dart';

/// Base class for concrete API clients owned by an [KApiBase].
///
/// Subclasses receive their parent [KApiBase] through the constructor and can
/// read shared state such as [baseUrl] and per-client cache values from it.
///
/// Example:
/// ```dart
/// class ChatsApi extends kickin.Api<Map<String, dynamic>> { // Map<String, dynamic> is the type of the cache for this API client
///   ChatsApi(super.parent);
/// }
/// ```
///
/// Use this for API modules that need access to the shared base
/// configuration.
abstract class KApi<CacheType> {
  final KApiBase _parent;
  KApi(this._parent);

  void log(String errorOrMsg) => "To be implemented!";

  final id = KApiBase._incrementId;

  @protected
  String get baseUrl => _parent._baseUrl;

  @protected
  CacheType? get cache => _parent._getCache(id);
  @protected
  void setCache(CacheType value) => _parent._setCache(id, value);

  Dio _api = Dio();
  Dio get api => _api;
  void resetDio() => _api = Dio();
}
