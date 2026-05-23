// ignore_for_file: public_member_api_docs, sort_constructors_first
// remember variants
part of '../api_base.dart';

sealed class _KRestRequest<TDecoded, T extends _KRestRequest<TDecoded, T>> {
  /// Shared request configuration used by every request wrapper in this file.
  const _KRestRequest(
    this._api, {
    required this.path,
    this.usePrimary = true,
    this.headers,
    this.data,
    this.options,
    this.queryParams,
    this.cancelToken,
    this.onReceiveProgress,
    this.resolveRequest,
    this.decoder,
    this.cacheResponse = false,
    this.logRequest = false,
    this.logResponse = false,
  });

  final KApi _api;
  final String path;
  final bool usePrimary;
  final Map<String, String>? headers;
  final Object? data;
  final Options? options;
  final Map<String, dynamic>? queryParams;
  final CancelToken? cancelToken;
  final void Function(int, int)? onReceiveProgress;
  final bool cacheResponse;

  /// Better to use [kDebugMode] or [kDebugPrint]
  final bool logRequest;

  /// Better to use [kDebugMode] or [kDebugPrint]
  final bool logResponse;

  /// This can be used to modify or replace the entire request operation
  final FutureOr<T> Function(T request)? resolveRequest;

  /// Converts the raw Dio response payload into the client-facing output type.
  final TDecoded Function(Object?)? decoder;

  /// Selects the Dio instance that matches [usePrimary].
  Dio get _dio => usePrimary ? _api._parent._primaryDio : _api._parent._externalDio;

  /// Builds the shared Dio [Options] object with any overridden headers.
  Options get _requestOptions => options?.copyWith(headers: headers) ?? Options(headers: headers);

  KApiBase get _apiBase => _api._parent;

  /// Builds a fallback [RequestOptions] object for error handling and offline decodes.
  RequestOptions _requestOptionsFor(String method) => RequestOptions(
    path: path,
    headers: headers,
    data: data,
    queryParameters: queryParams,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
    method: method,
  );

  Future<KResponse<Raw, TDecoded>> _runRequest<Raw>(
    T current,
    String method, {
    required Future<Response<Raw>> Function(T?) response,
  }) async {
    try {
      if (_apiBase._logRequests || logRequest) dev.log("API Request: $method $path", name: 'KApi', level: 1);
      final result = await response(resolveRequest == null ? null : await resolveRequest!(current));
      if (_apiBase._logResponses || logResponse) {
        dev.log("API Response: ${result.data}", name: 'KApi', level: 1);
      }
      return KResponse<Raw, TDecoded>(requestOptions: result.requestOptions, decoder: decoder);
    } catch (e) {
      return KResponse<Raw, TDecoded>(requestOptions: _requestOptionsFor(method), decoder: decoder, error: e);
    }
  }
}

/// GET request wrapper with an optional custom operation and response decoder.
class KGetRequest<TDecoded> extends _KRestRequest<TDecoded, KGetRequest<TDecoded>> {
  const KGetRequest(
    super._api, {
    required super.path,
    super.usePrimary,
    super.headers,
    super.data,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    super.resolveRequest,
    super.decoder,
    super.cacheResponse,
    super.logRequest,
    super.logResponse,
  });

  Future<KResponse<Raw, TDecoded>> getResponse<Raw>() => _runRequest<Raw>(
    this,
    'GET',
    response: (r) => _dio.get<Raw>(
      r?.path ?? path,
      options: r?.options ?? _requestOptions,
      data: r?.data ?? data,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
      onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
    ),
  );

  Future<TDecoded?> get() => getResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KGetRequest<TDecoded> copyWith({
    String? Function(String)? pathTransform,
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    TDecoded Function(dynamic)? decoder,
  }) => KGetRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    queryParams: queryParams ?? this.queryParams,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolveRequest: resolveRequest,
    decoder: decoder ?? this.decoder,
  );
}

/// POST request wrapper with send-progress support and optional response decoding.
class KPostRequest<TDecoded> extends _KRestRequest<TDecoded, KPostRequest<TDecoded>> {
  const KPostRequest(
    super._api, {
    required super.path,
    super.usePrimary,
    super.headers,
    super.data,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    this.onSendProgress,
    super.resolveRequest,
    super.decoder,
    super.cacheResponse,
    super.logRequest,
    super.logResponse,
  });

  final void Function(int, int)? onSendProgress;

  Future<KResponse<Raw, TDecoded>> postResponse<Raw>() => _runRequest<Raw>(
    this,
    'POST',
    response: (r) => _dio.post<Raw>(
      r?.path ?? path,
      options: r?.options ?? _requestOptions,
      data: r?.data ?? data,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
    ),
  );

  Future<TDecoded?> post() => postResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KPostRequest<TDecoded> copyWith({
    String? Function(String)? pathTransform,
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    TDecoded Function(dynamic)? decoder,
  }) => KPostRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    onSendProgress: onSendProgress ?? this.onSendProgress,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolveRequest: resolveRequest,
    decoder: decoder ?? this.decoder,
  );
}

/// PUT request wrapper with send-progress support and optional response decoding.
class KPutRequest<TDecoded> extends _KRestRequest<TDecoded, KPutRequest<TDecoded>> {
  const KPutRequest(
    super._api, {
    required super.path,
    super.usePrimary,
    super.headers,
    super.data,
    super.decoder,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    super.resolveRequest,
    this.onSendProgress,
    super.cacheResponse,
    super.logRequest,
    super.logResponse,
  });

  final void Function(int, int)? onSendProgress;

  Future<KResponse<Raw, TDecoded>> putResponse<Raw>() => _runRequest<Raw>(
    this,
    'PUT',
    response: (r) => _dio.put<Raw>(
      r?.path ?? path,
      options: r?.options ?? _requestOptions,
      data: r?.data ?? data,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
    ),
  );

  Future<TDecoded?> put() => putResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KPutRequest<TDecoded> copyWith({
    String? Function(String)? pathTransform,
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    TDecoded Function(dynamic)? decoder,
  }) => KPutRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    onSendProgress: onSendProgress ?? this.onSendProgress,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolveRequest: resolveRequest,
    decoder: decoder ?? this.decoder,
  );
}

/// PATCH request wrapper with send-progress support and optional response decoding.
class KPatchRequest<TDecoded> extends _KRestRequest<TDecoded, KPatchRequest<TDecoded>> {
  const KPatchRequest(
    super._api, {
    required super.path,
    super.usePrimary,
    super.headers,
    super.data,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    this.onSendProgress,
    super.resolveRequest,
    super.decoder,
    super.cacheResponse,
    super.logRequest,
    super.logResponse,
  });

  final void Function(int, int)? onSendProgress;

  Future<KResponse<Raw, TDecoded>> patchResponse<Raw>() => _runRequest<Raw>(
    this,
    'PATCH',
    response: (r) => _dio.patch<Raw>(
      r?.path ?? path,
      options: r?.options ?? _requestOptions,
      data: r?.data ?? data,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
    ),
  );

  Future<TDecoded?> patch() => patchResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KPatchRequest<TDecoded> copyWith({
    String? Function(String)? pathTransform,
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    TDecoded Function(dynamic)? decoder,
  }) => KPatchRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    onSendProgress: onSendProgress ?? this.onSendProgress,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolveRequest: resolveRequest,
    decoder: decoder ?? this.decoder,
  );
}

/// DELETE request wrapper with optional response decoding.
class KDeleteRequest<TDecoded> extends _KRestRequest<TDecoded, KDeleteRequest<TDecoded>> {
  const KDeleteRequest(
    super._api, {
    required super.path,
    super.usePrimary,
    super.headers,
    super.data,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    super.resolveRequest,
    super.decoder,
    super.cacheResponse,
    super.logRequest,
    super.logResponse,
  });

  Future<KResponse<Raw, TDecoded>> deleteResponse<Raw>() => _runRequest<Raw>(
    this,
    'DELETE',
    response: (r) => _dio.delete<Raw>(
      r?.path ?? path,
      options: r?.options ?? _requestOptions,
      data: r?.data ?? data,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
    ),
  );

  Future<TDecoded?> delete() => deleteResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KDeleteRequest<TDecoded> copyWith({
    String? Function(String)? pathTransform,
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    TDecoded Function(dynamic)? decoder,
  }) => KDeleteRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    resolveRequest: resolveRequest,
    decoder: decoder ?? this.decoder,
  );
}

/// Download request wrapper for saving remote files to disk.
class KDownloadRequest<TDecoded> extends _KRestRequest<TDecoded, KDownloadRequest<TDecoded>> {
  const KDownloadRequest(
    super._api, {
    required super.path,
    required this.savePath,
    super.usePrimary,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    super.resolveRequest,
    this.fileAccessMode = FileAccessMode.write,
    this.deleteOnError = true,
    super.cacheResponse,
    super.logRequest,
    super.logResponse,
  });

  /// The target file path or stream destination passed to Dio.
  final dynamic savePath;

  final FileAccessMode fileAccessMode;

  /// Deletes the partially downloaded file when the download fails.
  final bool deleteOnError;

  Future<KResponse<dynamic, TDecoded>> downloadResponse<Raw>() => _runRequest(
    this,
    "DOWNLOAD",
    response: (r) => _dio.download(
      r?.path ?? path,
      savePath,
      options: r?.options ?? options,
      data: r?.data ?? data,
      fileAccessMode: fileAccessMode,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
      onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      deleteOnError: deleteOnError,
    ),
  );

  Future<void> download() => downloadResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KDownloadRequest copyWith({
    String? Function(String)? pathTransform,
    bool? usePrimary,
    dynamic savePath,
    Options? options,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    bool? deleteOnError,
  }) => KDownloadRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    savePath: savePath ?? this.savePath,
    usePrimary: usePrimary ?? this.usePrimary,
    options: options ?? this.options,
    queryParams: queryParams ?? this.queryParams,
    cancelToken: cancelToken ?? this.cancelToken,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolveRequest: resolveRequest,
    deleteOnError: deleteOnError ?? this.deleteOnError,
  );
}

class KRequest<TDecoded> extends _KRestRequest<TDecoded, KRequest<TDecoded>> {
  const KRequest(
    super._api, {
    required super.path,
    super.usePrimary,
    super.headers,
    super.data,
    super.decoder,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    super.resolveRequest,
    this.onSendProgress,
    super.cacheResponse,
    super.logRequest,
    super.logResponse,
  });
  final void Function(int, int)? onSendProgress;

  Future<KResponse<Raw, TDecoded>> request<Raw>() => _runRequest<Raw>(
    this,
    'REQUEST',
    response: (r) => _dio.request<Raw>(
      r?.path ?? path,
      options: r?.options ?? _requestOptions,
      data: r?.data ?? data,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
      onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
    ),
  );

  Future<TDecoded?> get() => request().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KRequest<TDecoded> copyWith({
    String? Function(String)? pathTransform,
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    TDecoded Function(dynamic)? decoder,
  }) => KRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    queryParams: queryParams ?? this.queryParams,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolveRequest: resolveRequest,
    decoder: decoder ?? this.decoder,
  );
}
