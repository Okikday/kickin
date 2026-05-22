// ignore_for_file: public_member_api_docs, sort_constructors_first
// remember variants
part of '../api_base.dart';

Dio _primary = Dio();
Dio _external = Dio();

class KRestRequest<In, Out> {
  /// Shared request configuration used by every request wrapper in this file.
  const KRestRequest(
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
  final Future<KRestRequest<In, Out>> Function(KRestRequest<In, Out> request)? resolveRequest;

  /// Converts the raw Dio response payload into the client-facing output type.
  final Out Function(In?)? decode;

  /// Replaces the primary Dio instance used by requests that opt into it.
  void setPrimaryDio(Dio dio) => _primary = dio;

  /// Replaces the external Dio instance used by requests that opt out of the primary client.
  void setExternal(Dio dio) => _external = dio;

  /// Selects the Dio instance that matches [usePrimary].
  Dio get _dio => usePrimary ? _primary : _external;

  /// Builds the shared Dio [Options] object with any overridden headers.
  Options get _requestOptions => options?.copyWith(headers: headers) ?? Options(headers: headers);

  /// Builds a fallback [RequestOptions] object for error handling and offline transforms.
  RequestOptions _requestOptionsFor(String method) => RequestOptions(
    path: path,
    headers: headers,
    data: data,
    queryParameters: queryParams,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
    method: method,
  );

  KRestRequest<In, Out> copyWith({
    String? path,
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Options? options,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    Future<KRestRequest<In, Out>> Function(KRestRequest<In, Out> request)? resolveRequest,
    Out Function(In?)? decode,
  }) {
    return KRestRequest<In, Out>(
      path ?? this.path,
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
}

/// GET request wrapper with an optional custom operation and response decoder.
class KGetRequest<In, Out> extends KRestRequest<In, Out> {
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
      final r = await resolveRequest?.call(this);
      final response = await _dio.get<In>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      );
      return KResponse(requestOptions: response.requestOptions, transform: decode);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('GET'), transform: decode);
    }
  }

  Future<Out?> get() => getResponse().then((v) => v.value);
}

/// POST request wrapper with send-progress support and optional response decoding.
class KPostRequest<In, Out> extends KRestRequest<In, Out> {
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
      final r = await resolveRequest?.call(this);
      final response = await _dio.post<In>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      );
      return KResponse(requestOptions: response.requestOptions, transform: decode);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('POST'), transform: decode);
    }
  }

  Future<Out?> post() => postResponse().then((v) => v.value);
}

/// PUT request wrapper with send-progress support and optional response decoding.
class KPutRequest<In, Out> extends KRestRequest<In, Out> {
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
      final r = await resolveRequest?.call(this);
      final response = await _dio.put<In>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      );
      return KResponse(requestOptions: response.requestOptions, transform: decode);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('PUT'), transform: decode);
    }
  }

  Future<Out?> put() => putResponse().then((v) => v.value);
}

/// PATCH request wrapper with send-progress support and optional response decoding.
class KPatchRequest<In, Out> extends KRestRequest<In, Out> {
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
      final r = await resolveRequest?.call(this);
      final response = await _dio.patch<In>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      );
      return KResponse(requestOptions: response.requestOptions, transform: decode);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('PATCH'), transform: decode);
    }
  }

  Future<Out?> patch() => patchResponse().then((v) => v.value);
}

/// DELETE request wrapper with optional response decoding.
class KDeleteRequest<In, Out> extends KRestRequest<In, Out> {
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
      final r = await resolveRequest?.call(this);
      final response = await _dio.delete<In>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions,
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
      );
      return KResponse(requestOptions: response.requestOptions, transform: decode);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('DELETE'), transform: decode);
    }
  }

  Future<Out?> delete() => deleteResponse().then((v) => v.value);
}

/// Download request wrapper for saving remote files to disk.
class KDownloadRequest<In, Out> extends KRestRequest<In, Out> {
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
      final r = await resolveRequest?.call(this);
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
      return KResponse(requestOptions: response.requestOptions, transform: decode);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('DOWNLOAD'), transform: decode);
    }
  }

  Future<Out?> download() => downloadResponse().then((v) => v.value);
}

class KSomeRequest<In, Out> extends KRestRequest<In, Out> {
  const KSomeRequest(
    super.path,
    this.type, {
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
  final String type;

  Future<KResponse<In?, Out>> someResponse() async {
    try {
      final r = await resolveRequest?.call(this);
      final response = await _dio.request<In>(
        r?.path ?? path,
        options: r?.options ?? _requestOptions.copyWith(method: type),
        data: r?.data ?? data,
        queryParameters: r?.queryParams ?? queryParams,
        cancelToken: r?.cancelToken ?? cancelToken,
        onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      );
      return KResponse(requestOptions: response.requestOptions, transform: decode);
    } catch (e) {
      return KResponse(requestOptions: _requestOptionsFor('SOME'), transform: decode);
    }
  }

  Future<Out?> some() => someResponse().then((v) => v.value);
}
