// ignore_for_file: public_member_api_docs, sort_constructors_first
// remember variants
part of '../api_base.dart';

Dio _primary = Dio();
Dio _external = Dio();

sealed class _KRestRequest<In, Out> {
  /// Shared request configuration used by every request wrapper in this file.
  const _KRestRequest(
    this.path, {
    this.usePrimary = true,
    this.headers,
    this.data,
    this.options,
    this.queryParams,
    this.cancelToken,
    this.onReceiveProgress,
    this.resolveRequest,
    this.decode,
  });

  final String path;
  final bool usePrimary;
  final Map<String, String>? headers;
  final Object? data;
  final Options? options;
  final Map<String, dynamic>? queryParams;
  final CancelToken? cancelToken;
  final void Function(int, int)? onReceiveProgress;

  /// This can be used to modify or replace the entire request operation
  final FutureOr<_KRestRequest<In, Out>> Function(_KRestRequest<In, Out> request)? resolveRequest;

  /// Converts the raw Dio response payload into the client-facing output type.
  final Out Function(In?)? decode;

  /// Selects the Dio instance that matches [usePrimary].
  Dio get _dio => usePrimary ? _primary : _external;

  /// Builds the shared Dio [Options] object with any overridden headers.
  Options get _requestOptions => options?.copyWith(headers: headers) ?? Options(headers: headers);

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
}

/// GET request wrapper with an optional custom operation and response decoder.
class KGetRequest<In, Out> extends _KRestRequest<In, Out> {
  const KGetRequest(
    super.path, {
    super.usePrimary,
    super.headers,
    super.data,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    super.resolveRequest,
    super.decode,
  });

  Future<KResponse<In?, Out>> getResponse() async {
    try {
      final r = resolveRequest != null ? await resolveRequest!(this) : null;
      final response = await _dio.get<In>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      );
      return KResponse(requestOptions: response.requestOptions, decode: decode);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('GET'), decode: decode);
    }
  }

  Future<Out?> get() => getResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KGetRequest<In, Out> copyWith({
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    Out Function(In?)? decode,
  }) => KGetRequest<In, Out>(
    path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    queryParams: queryParams ?? this.queryParams,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolveRequest: resolveRequest,
    decode: decode ?? this.decode,
  );
}

/// POST request wrapper with send-progress support and optional response decoding.
class KPostRequest<In, Out> extends _KRestRequest<In, Out> {
  const KPostRequest(
    super.path, {
    super.usePrimary,
    super.headers,
    super.data,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    this.onSendProgress,
    super.resolveRequest,
    super.decode,
  });

  final void Function(int, int)? onSendProgress;

  Future<KResponse<In?, Out>> postResponse() async {
    try {
      final r = resolveRequest != null ? await resolveRequest!(this) : null;
      final response = await _dio.post<In>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      );
      return KResponse(requestOptions: response.requestOptions, decode: decode);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('POST'), decode: decode);
    }
  }

  Future<Out?> post() => postResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KPostRequest<In, Out> copyWith({
    Map<String, String>? headers,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Out Function(In?)? decode,
  }) => KPostRequest<In, Out>(
    path,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    onSendProgress: onSendProgress ?? this.onSendProgress,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolveRequest: resolveRequest,
    decode: decode ?? this.decode,
  );
}

/// PUT request wrapper with send-progress support and optional response decoding.
class KPutRequest<In, Out> extends _KRestRequest<In, Out> {
  const KPutRequest(
    super.path, {
    super.usePrimary,
    super.headers,
    super.data,
    super.decode,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    super.resolveRequest,
    this.onSendProgress,
  });

  final void Function(int, int)? onSendProgress;

  Future<KResponse<In?, Out>> putResponse() async {
    try {
      final r = resolveRequest != null ? await resolveRequest!(this) : null;
      final response = await _dio.put<In>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      );
      return KResponse(requestOptions: response.requestOptions, decode: decode);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('PUT'), decode: decode);
    }
  }

  Future<Out?> put() => putResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KPutRequest<In, Out> copyWith({
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Out Function(In?)? decode,
  }) => KPutRequest<In, Out>(
    path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    onSendProgress: onSendProgress ?? this.onSendProgress,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolveRequest: resolveRequest,
    decode: decode ?? this.decode,
  );
}

/// PATCH request wrapper with send-progress support and optional response decoding.
class KPatchRequest<In, Out> extends _KRestRequest<In, Out> {
  const KPatchRequest(
    super.path, {
    super.usePrimary,
    super.headers,
    super.data,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    this.onSendProgress,
    super.resolveRequest,
    super.decode,
  });

  final void Function(int, int)? onSendProgress;

  Future<KResponse<In?, Out>> patchResponse() async {
    try {
      final r = resolveRequest != null ? await resolveRequest!(this) : null;
      final response = await _dio.patch<In>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      );
      return KResponse(requestOptions: response.requestOptions, decode: decode);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('PATCH'), decode: decode);
    }
  }

  Future<Out?> patch() => patchResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KPatchRequest<In, Out> copyWith({
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Out Function(In?)? decode,
  }) => KPatchRequest<In, Out>(
    path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    onSendProgress: onSendProgress ?? this.onSendProgress,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolveRequest: resolveRequest,
    decode: decode ?? this.decode,
  );
}

/// DELETE request wrapper with optional response decoding.
class KDeleteRequest<In, Out> extends _KRestRequest<In, Out> {
  const KDeleteRequest(
    super.path, {
    super.usePrimary,
    super.headers,
    super.data,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    super.resolveRequest,
    super.decode,
  });

  Future<KResponse<In?, Out>> deleteResponse() async {
    try {
      final r = resolveRequest != null ? await resolveRequest!(this) : null;
      final response = await _dio.delete<In>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
      );
      return KResponse(requestOptions: response.requestOptions, decode: decode);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('DELETE'), decode: decode);
    }
  }

  Future<Out?> delete() => deleteResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KDeleteRequest<In, Out> copyWith({
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    Out Function(In?)? decode,
  }) => KDeleteRequest<In, Out>(
    path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    resolveRequest: resolveRequest,
    decode: decode ?? this.decode,
  );
}

/// Download request wrapper for saving remote files to disk.
class KDownloadRequest<In, Out> extends _KRestRequest<In, Out> {
  const KDownloadRequest(
    super.path, {
    required this.savePath,
    super.usePrimary,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    super.resolveRequest,
    this.fileAccessMode = FileAccessMode.write,
    this.deleteOnError = true,
  });

  /// The target file path or stream destination passed to Dio.
  final dynamic savePath;

  final FileAccessMode fileAccessMode;

  /// Deletes the partially downloaded file when the download fails.
  final bool deleteOnError;

  Future<KResponse<In?, Out>> downloadResponse() async {
    try {
      final r = resolveRequest != null ? await resolveRequest!(this) : null;
      final response = await _dio.download(
        r?.path ?? path,
        savePath,
        options: r?.options ?? options,
        data: r?.data ?? data,
        fileAccessMode: fileAccessMode,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
        deleteOnError: deleteOnError,
      );
      return KResponse(requestOptions: response.requestOptions, decode: decode);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('DOWNLOAD'), decode: decode);
    }
  }

  Future<void> download() => downloadResponse();

  /// Returns a copy of this request with the supplied overrides.
  KDownloadRequest copyWith({
    bool? usePrimary,
    dynamic savePath,
    Options? options,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    bool? deleteOnError,
  }) => KDownloadRequest<In, Out>(
    path,
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
