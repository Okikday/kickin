part of 'api_base.dart';

/// Base class for concrete API clients owned by an [ApiBase].
///
/// Subclasses receive their parent [ApiBase] through the constructor and can
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
abstract class Api<CacheType> {
  final ApiBase _parent;
  Api(this._parent);

  final id = ApiBase._incrementId;

  String get baseUrl => _parent._baseUrl;

  CacheType? get cache => _parent._getCache(id);
  void setCache(CacheType value) => _parent._setCache(id, value);

  // void listener() {
  //   // Doing nothing
  // }
}
