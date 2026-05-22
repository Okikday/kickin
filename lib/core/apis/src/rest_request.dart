// ignore_for_file: public_member_api_docs, sort_constructors_first
// remember variants
part of '../api_base.dart';

typedef Decoder<Raw, Formatted> = Formatted Function(Raw);

Dio _primary = Dio();
Dio _external = Dio();

sealed class _KRestRequest<Raw, Formatted, T extends _KRestRequest<Raw, Formatted, T>> {
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
    this.decoder,
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
  final FutureOr<T> Function(T request)? resolveRequest;

  /// Converts the raw Dio response payload into the client-facing output type.
  final Decoder<Raw, Formatted>? decoder;

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
class KGetRequest<Raw, Formatted> extends _KRestRequest<Raw, Formatted, KGetRequest<Raw, Formatted>> {
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
    super.decoder,
  });

  Future<KResponse<Raw, Formatted>> getResponse() async {
    try {
      final r = resolveRequest != null ? await resolveRequest!(this) : null;
      final response = await _dio.get<Raw>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      );
      return KResponse(requestOptions: response.requestOptions, decoder: decoder);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('GET'), decoder: decoder, error: e);
    }
  }

  Future<Formatted?> get() => getResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KGetRequest<Raw, Formatted> copyWith({
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    Decoder<Raw, Formatted>? decode,
  }) => KGetRequest<Raw, Formatted>(
    path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    queryParams: queryParams ?? this.queryParams,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolveRequest: resolveRequest,
    decoder: decode ?? this.decoder,
  );
}

/// POST request wrapper with send-progress support and optional response decoding.
class KPostRequest<Raw, Formatted> extends _KRestRequest<Raw, Formatted, KPostRequest<Raw, Formatted>> {
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
    super.decoder,
  });

  final void Function(int, int)? onSendProgress;

  Future<KResponse<Raw, Formatted>> postResponse() async {
    try {
      final r = resolveRequest != null ? await resolveRequest!(this) : null;
      final response = await _dio.post<Raw>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      );
      return KResponse(requestOptions: response.requestOptions, decoder: decoder);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('POST'), decoder: decoder, error: e);
    }
  }

  Future<Formatted?> post() => postResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KPostRequest<Raw, Formatted> copyWith({
    Map<String, String>? headers,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Decoder<Raw, Formatted>? decode,
  }) => KPostRequest<Raw, Formatted>(
    path,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    onSendProgress: onSendProgress ?? this.onSendProgress,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolveRequest: resolveRequest,
    decoder: decode ?? this.decoder,
  );
}

/// PUT request wrapper with send-progress support and optional response decoding.
class KPutRequest<Raw, Formatted> extends _KRestRequest<Raw, Formatted, KPutRequest<Raw, Formatted>> {
  const KPutRequest(
    super.path, {
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
  });

  final void Function(int, int)? onSendProgress;

  Future<KResponse<Raw, Formatted>> putResponse() async {
    try {
      final r = resolveRequest != null ? await resolveRequest!(this) : null;
      final response = await _dio.put<Raw>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      );
      return KResponse(requestOptions: response.requestOptions, decoder: decoder);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('PUT'), decoder: decoder);
    }
  }

  Future<Formatted?> put() => putResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KPutRequest<Raw, Formatted> copyWith({
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Decoder<Raw, Formatted>? decode,
  }) => KPutRequest<Raw, Formatted>(
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
    decoder: decode ?? this.decoder,
  );
}

/// PATCH request wrapper with send-progress support and optional response decoding.
class KPatchRequest<Raw, Formatted> extends _KRestRequest<Raw, Formatted, KPatchRequest<Raw, Formatted>> {
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
    super.decoder,
  });

  final void Function(int, int)? onSendProgress;

  Future<KResponse<Raw, Formatted>> patchResponse() async {
    try {
      final r = resolveRequest != null ? await resolveRequest!(this) : null;
      final response = await _dio.patch<Raw>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      );
      return KResponse(requestOptions: response.requestOptions, decoder: decoder);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('PATCH'), decoder: decoder);
    }
  }

  Future<Formatted?> patch() => patchResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KPatchRequest<Raw, Formatted> copyWith({
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Decoder<Raw, Formatted>? decode,
  }) => KPatchRequest<Raw, Formatted>(
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
    decoder: decode ?? this.decoder,
  );
}

/// DELETE request wrapper with optional response decoding.
class KDeleteRequest<Raw, Formatted> extends _KRestRequest<Raw, Formatted, KDeleteRequest<Raw, Formatted>> {
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
    super.decoder,
  });

  Future<KResponse<Raw, Formatted>> deleteResponse() async {
    try {
      final r = resolveRequest != null ? await resolveRequest!(this) : null;
      final response = await _dio.delete<Raw>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
      );
      return KResponse(requestOptions: response.requestOptions, decoder: decoder);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('DELETE'), decoder: decoder, error: e);
    }
  }

  Future<Formatted?> delete() => deleteResponse().then((v) => v.value);

  /// Returns a copy of this request with the supplied overrides.
  KDeleteRequest<Raw, Formatted> copyWith({
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    Decoder<Raw, Formatted>? decode,
  }) => KDeleteRequest<Raw, Formatted>(
    path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: options ?? this.options,
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    resolveRequest: resolveRequest,
    decoder: decode ?? this.decoder,
  );
}

/// Download request wrapper for saving remote files to disk.
class KDownloadRequest<Raw, Formatted> extends _KRestRequest<Raw, Formatted, KDownloadRequest<Raw, Formatted>> {
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

  Future<KResponse<Raw, Formatted>> downloadResponse() async {
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
      return KResponse(requestOptions: response.requestOptions, decoder: decoder);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('DOWNLOAD'), decoder: decoder, error: e);
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
  }) => KDownloadRequest<Raw, Formatted>(
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
