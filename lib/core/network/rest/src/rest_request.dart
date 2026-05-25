// ignore_for_file: public_member_api_docs, sort_constructors_first
// remember variants
part of '../rest_api_base.dart';

enum RequestMethod { GET, POST, PATCH, PUT, DELETE, DOWNLOAD, REQUEST }

class KRestRequest<TDecoded> {
  /// Shared request configuration used by every request wrapper in this file.
  KRestRequest(
    this._api, {
    required this.path,
    this.usePrimary = true,
    this.headers,
    this.data,
    Options? options,
    this.queryParams,
    this.cancelToken,
    this.onReceiveProgress,
    this.decoder,
    this.logOptions,
    this.useBaseUrl = true,
  }) : options = options?.copyWith(headers: headers) ?? Options(headers: headers);

  final KRestApi _api;
  final String path;
  final bool usePrimary;

  /// It will replace the one in [Options.headers], don't provide if you wish to use the one in the Options
  final Map<String, String>? headers;
  final Object? data;
  final Options? options;
  final Map<String, dynamic>? queryParams;
  final CancelToken? cancelToken;
  final void Function(int, int)? onReceiveProgress;

  final LogOptions? logOptions;

  /// Set to true by default. You can set to false if you don't want to append with the baseUrl from the parent [KRestApiBase] and want to provide a full URL in [path] instead.
  /// Doesn't have any effect if the [KRestApiBase] doesn't have a [baseUrl] configured, in which case the [path] is used as-is regardless of this flag.
  final bool useBaseUrl;

  /// Converts the raw Dio response payload into the client-facing output type.
  /// [data] == [Response.data]
  final TDecoded Function(dynamic data, Response _)? decoder;

  /// Selects the Dio instance that matches [usePrimary].
  Dio get _dio => usePrimary ? _api._parent._primaryDio : _api._parent._externalDio;

  KRestApiBase get _apiBase => _api._parent;

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

  /// For getting the final path after considering [useBaseUrl] and the parent's [baseUrl]. This is used internally for logging and error handling, but you can also use it in your custom [resolve] logic or when overriding the path in the copyWith methods.
  late final _transformedPath = (useBaseUrl && _apiBase._baseUrl.isNotEmpty) ? "${_apiBase._baseUrl}$path" : path;
  String get transformedPath => _transformedPath;

  Future<KResponse<Raw, TDecoded>> _runRequest<Raw>(String method, {required Future<Response<Raw>> response}) async {
    if (kDebugMode) _logRequest(logOptions ?? _apiBase._logOptions, method);
    final result = await response;
    if (kDebugMode) _logResponse(logOptions ?? _apiBase._logOptions, method, result);

    return KResponse<Raw, TDecoded>.fromDioResponse(result, decoder: decoder);
  }

  Future<KResponse<Raw, TDecoded>> _tryRunRequest<Raw>(String method, {required Future<Response<Raw>> response}) async {
    try {
      final result = await _runRequest(method, response: response);
      return result;
    } catch (e) {
      final response = KResponse<Raw, TDecoded>.fromDioResponse(
        Response(requestOptions: _requestOptionsFor(method)),
        decoder: decoder,
        error: e,
      );
      if (kDebugMode) _logResponse(logOptions ?? _apiBase._logOptions, method, response);
      return response;
    }
  }

  KGetRequest<TDecoded> toGetRequest() => KGetRequest<TDecoded>.from(this);
  KPostRequest<TDecoded> toPostRequest() => KPostRequest<TDecoded>.from(this);
  KPutRequest<TDecoded> toPutRequest() => KPutRequest<TDecoded>.from(this);
  KPatchRequest<TDecoded> toPatchRequest() => KPatchRequest<TDecoded>.from(this);
  KDeleteRequest<TDecoded> toDeleteRequest() => KDeleteRequest<TDecoded>.from(this);
  KDownloadRequest<TDecoded> toDownloadRequest({required dynamic savePath}) =>
      KDownloadRequest<TDecoded>.from(this, savePath: savePath);
  KRequest<TDecoded> toRequest() => KRequest<TDecoded>.from(this);

  void _logRequest(LogOptions logOptions, String method) {
    if (logOptions.parts.isEmpty) return;

    final Map<String, dynamic> output = {};

    if (logOptions.parts.contains(LogPart.queryParams) && queryParams != null) {
      output['Query'] = queryParams;
    }
    if (logOptions.parts.contains(LogPart.requestBody) && data != null) {
      output['Body'] = data;
    }
    if (logOptions.parts.contains(LogPart.requestHeaders) && headers != null) {
      output['Headers'] = headers;
    }

    final title = 'Request($method): $_transformedPath';
    if (output.isNotEmpty) {
      final prettyJson = const JsonEncoder.withIndent('  ').convert(output);

      NetworkLog.request('$title\n$prettyJson');
    } else {
      NetworkLog.request(title);
    }
  }

  void _logResponse<Raw>(LogOptions logOptions, String method, dynamic result) {
    if (logOptions.parts.isEmpty) return;
    final bool isOk = result.statusCode != null && result.statusCode! >= 200 && result.statusCode! < 300;
    final Map<String, dynamic> output = {};

    if (logOptions.parts.contains(LogPart.responseBody) && result is Response && result.data != null) {
      String rawData = result.data.toString();

      if (rawData.length > logOptions.maxLogLength) {
        output['Data'] = '${rawData.substring(0, logOptions.maxLogLength)}... [TRUNCATED]';
      } else {
        output['Data'] = result.data;
      }
    }

    if (logOptions.parts.contains(LogPart.responseHeaders) && result is Response) {
      output['Headers'] = result.headers.map;
    }

    if (!isOk && logOptions.parts.contains(LogPart.errors) && result is KResponse && result.error != null) {
      output['Error Details'] = result.error.toString();
    }

    final title = 'Response(${result.statusCode ?? 'ERR'}): $_transformedPath';

    final prettyJson = output.isNotEmpty ? '\n${const JsonEncoder.withIndent('  ').convert(output)}' : '';

    if (isOk) {
      NetworkLog.success('$title$prettyJson');
    } else {
      NetworkLog.error('$title$prettyJson');
    }
  }

  String toString() {
    return 'KRestRequest(path: $path, usePrimary: $usePrimary, headers: $headers, data: $data, options: $options, queryParams: $queryParams, cancelToken: $cancelToken, onReceiveProgress: $onReceiveProgress, logOptions: $logOptions, useBaseUrl: $useBaseUrl)';
  }
}

/// GET request wrapper with an optional custom operation and response decoder.
class KGetRequest<TDecoded> extends KRestRequest<TDecoded> {
  KGetRequest(
    super._api, {
    required super.path,
    super.usePrimary,
    super.headers,
    super.data,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    super.decoder,
    super.logOptions,
    super.useBaseUrl,
    this.resolve,
  });

  static const method = 'GET';

  /// This can be used to modify or replace the entire request operation
  final FutureOr<KGetRequest<TDecoded>> Function(KGetRequest<TDecoded>)? resolve;

  Future<KResponse<Raw, TDecoded>> _getResponse<Raw>(bool tryRun) async {
    final r = resolve == null ? null : await resolve!(this);

    final response = _dio.get<Raw>(
      r?.transformedPath ?? _transformedPath,
      options: r?.options ?? options,
      data: r?.data ?? data,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
      onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
    );
    return tryRun ? _tryRunRequest(method, response: response) : _runRequest<Raw>(method, response: response);
  }

  Future<KResponse<Raw, TDecoded>> getResponse<Raw>() => _getResponse(false);

  Future<KResponse<Raw, TDecoded>> tryGetResponse<Raw>() => _getResponse(true);

  Future<TDecoded?> get() => _getResponse(false).then((v) => v.value);

  Future<TDecoded?> tryGet<Raw>() => _getResponse(true).then((v) => v.value);

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
    LogOptions? logOptions,
    bool? useBaseUrl,
    TDecoded Function(dynamic data, Response _)? decoder,
  }) => KGetRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    queryParams: queryParams ?? this.queryParams,
    options: headers != null ? options : (options ?? this.options),
    cancelToken: cancelToken ?? this.cancelToken,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolve: resolve,
    decoder: decoder ?? this.decoder,
    logOptions: logOptions ?? this.logOptions,
    useBaseUrl: useBaseUrl ?? this.useBaseUrl,
  );

  factory KGetRequest.from(
    KRestRequest<TDecoded> r, {
    FutureOr<KGetRequest<TDecoded>> Function(KGetRequest<TDecoded>)? resolve,
  }) => KGetRequest<TDecoded>(
    r._api,
    path: r.path,
    usePrimary: r.usePrimary,
    headers: r.headers,
    data: r.data,
    options: r.options,
    queryParams: r.queryParams,
    cancelToken: r.cancelToken,
    onReceiveProgress: r.onReceiveProgress,
    resolve: resolve,
    decoder: r.decoder,
    useBaseUrl: r.useBaseUrl,
    logOptions: r.logOptions,
  );
}

class KPostRequest<TDecoded> extends KRestRequest<TDecoded> {
  KPostRequest(
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
    super.decoder,
    super.logOptions,
    super.useBaseUrl,
    this.resolve,
  });

  static const method = 'POST';

  final void Function(int, int)? onSendProgress;
  final FutureOr<KPostRequest<TDecoded>> Function(KPostRequest<TDecoded>)? resolve;

  Future<KResponse<Raw, TDecoded>> _postResponse<Raw>(bool tryRun) async {
    final r = resolve == null ? null : await resolve!(this);

    final response = _dio.post<Raw>(
      r?.transformedPath ?? _transformedPath,
      options: r?.options ?? options,
      data: r?.data ?? data,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
      onSendProgress: r?.onSendProgress ?? onSendProgress,
      onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
    );
    return tryRun ? _tryRunRequest(method, response: response) : _runRequest<Raw>(method, response: response);
  }

  Future<KResponse<Raw, TDecoded>> postResponse<Raw>() => _postResponse(false);
  Future<KResponse<Raw, TDecoded>> tryPostResponse<Raw>() => _postResponse(true);
  Future<TDecoded?> post() => _postResponse(false).then((v) => v.value);
  Future<TDecoded?> tryPost() => _postResponse(true).then((v) => v.value);

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
    LogOptions? logOptions,
    bool? useBaseUrl,
    TDecoded Function(dynamic data, Response _)? decoder,
  }) => KPostRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: headers != null ? options : (options ?? this.options),
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    onSendProgress: onSendProgress ?? this.onSendProgress,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolve: resolve,
    decoder: decoder ?? this.decoder,
    logOptions: logOptions ?? this.logOptions,
    useBaseUrl: useBaseUrl ?? this.useBaseUrl,
  );

  factory KPostRequest.from(
    KRestRequest<TDecoded> r, {
    FutureOr<KPostRequest<TDecoded>> Function(KPostRequest<TDecoded>)? resolve,
  }) => KPostRequest<TDecoded>(
    r._api,
    path: r.path,
    usePrimary: r.usePrimary,
    headers: r.headers,
    data: r.data,
    options: r.options,
    queryParams: r.queryParams,
    cancelToken: r.cancelToken,
    onReceiveProgress: r.onReceiveProgress,
    resolve: resolve,
    decoder: r.decoder,
    useBaseUrl: r.useBaseUrl,
    logOptions: r.logOptions,
  );
}

/// PUT request wrapper with send-progress support and optional response decoding.
class KPutRequest<TDecoded> extends KRestRequest<TDecoded> {
  KPutRequest(
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
    this.onSendProgress,
    super.logOptions,
    super.useBaseUrl,
    this.resolve,
  });

  static const method = 'PUT';

  final void Function(int, int)? onSendProgress;
  final FutureOr<KPutRequest<TDecoded>> Function(KPutRequest<TDecoded>)? resolve;

  Future<KResponse<Raw, TDecoded>> _putResponse<Raw>(bool tryRun) async {
    final r = resolve == null ? null : await resolve!(this);

    final response = _dio.put<Raw>(
      r?.transformedPath ?? _transformedPath,
      options: r?.options ?? options,
      data: r?.data ?? data,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
      onSendProgress: r?.onSendProgress ?? onSendProgress,
      onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
    );
    return tryRun ? _tryRunRequest(method, response: response) : _runRequest<Raw>(method, response: response);
  }

  Future<KResponse<Raw, TDecoded>> putResponse<Raw>() => _putResponse(false);
  Future<KResponse<Raw, TDecoded>> tryPutResponse<Raw>() => _putResponse(true);
  Future<TDecoded?> put() => _putResponse(false).then((v) => v.value);
  Future<TDecoded?> tryPut() => _putResponse(true).then((v) => v.value);

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
    LogOptions? logOptions,
    bool? useBaseUrl,
    TDecoded Function(dynamic data, Response _)? decoder,
  }) => KPutRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: headers != null ? options : (options ?? this.options),
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    onSendProgress: onSendProgress ?? this.onSendProgress,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolve: resolve,
    decoder: decoder ?? this.decoder,
    logOptions: logOptions ?? this.logOptions,
    useBaseUrl: useBaseUrl ?? this.useBaseUrl,
  );

  factory KPutRequest.from(
    KRestRequest<TDecoded> r, {
    FutureOr<KPutRequest<TDecoded>> Function(KPutRequest<TDecoded>)? resolve,
  }) => KPutRequest<TDecoded>(
    r._api,
    path: r.path,
    usePrimary: r.usePrimary,
    headers: r.headers,
    data: r.data,
    options: r.options,
    queryParams: r.queryParams,
    cancelToken: r.cancelToken,
    onReceiveProgress: r.onReceiveProgress,
    resolve: resolve,
    decoder: r.decoder,
    useBaseUrl: r.useBaseUrl,
    logOptions: r.logOptions,
  );
}

/// PATCH request wrapper with send-progress support and optional response decoding.
class KPatchRequest<TDecoded> extends KRestRequest<TDecoded> {
  KPatchRequest(
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
    super.decoder,
    super.logOptions,
    super.useBaseUrl,
    this.resolve,
  });

  static const method = 'PATCH';

  final void Function(int, int)? onSendProgress;
  final FutureOr<KPatchRequest<TDecoded>> Function(KPatchRequest<TDecoded>)? resolve;

  Future<KResponse<Raw, TDecoded>> _patchResponse<Raw>(bool tryRun) async {
    final r = resolve == null ? null : await resolve!(this);

    final response = _dio.patch<Raw>(
      r?.transformedPath ?? _transformedPath,
      options: r?.options ?? options,
      data: r?.data ?? data,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
      onSendProgress: r?.onSendProgress ?? onSendProgress,
      onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
    );
    return tryRun ? _tryRunRequest(method, response: response) : _runRequest<Raw>(method, response: response);
  }

  Future<KResponse<Raw, TDecoded>> patchResponse<Raw>() => _patchResponse(false);
  Future<KResponse<Raw, TDecoded>> tryPatchResponse<Raw>() => _patchResponse(true);
  Future<TDecoded?> patch() => _patchResponse(false).then((v) => v.value);
  Future<TDecoded?> tryPatch() => _patchResponse(true).then((v) => v.value);

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
    LogOptions? logOptions,
    bool? useBaseUrl,
    TDecoded Function(dynamic data, Response _)? decoder,
  }) => KPatchRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: headers != null ? options : (options ?? this.options),
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    onSendProgress: onSendProgress ?? this.onSendProgress,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolve: resolve,
    decoder: decoder ?? this.decoder,
    logOptions: logOptions ?? this.logOptions,
    useBaseUrl: useBaseUrl ?? this.useBaseUrl,
  );

  factory KPatchRequest.from(
    KRestRequest<TDecoded> r, {
    FutureOr<KPatchRequest<TDecoded>> Function(KPatchRequest<TDecoded>)? resolve,
  }) => KPatchRequest<TDecoded>(
    r._api,
    path: r.path,
    usePrimary: r.usePrimary,
    headers: r.headers,
    data: r.data,
    options: r.options,
    queryParams: r.queryParams,
    cancelToken: r.cancelToken,
    onReceiveProgress: r.onReceiveProgress,
    resolve: resolve,
    decoder: r.decoder,
    useBaseUrl: r.useBaseUrl,
    logOptions: r.logOptions,
  );
}

/// DELETE request wrapper with optional response decoding.
class KDeleteRequest<TDecoded> extends KRestRequest<TDecoded> {
  KDeleteRequest(
    super._api, {
    required super.path,
    super.usePrimary,
    super.headers,
    super.data,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    super.decoder,
    super.logOptions,
    super.useBaseUrl,
    this.resolve,
  });

  static const method = 'DELETE';

  final FutureOr<KDeleteRequest<TDecoded>> Function(KDeleteRequest<TDecoded>)? resolve;

  Future<KResponse<Raw, TDecoded>> _deleteResponse<Raw>(bool tryRun) async {
    final r = resolve == null ? null : await resolve!(this);

    final response = _dio.delete<Raw>(
      r?.transformedPath ?? _transformedPath,
      options: r?.options ?? options,
      data: r?.data ?? data,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
    );
    return tryRun ? _tryRunRequest(method, response: response) : _runRequest<Raw>(method, response: response);
  }

  Future<KResponse<Raw, TDecoded>> deleteResponse<Raw>() => _deleteResponse(false);
  Future<KResponse<Raw, TDecoded>> tryDeleteResponse<Raw>() => _deleteResponse(true);
  Future<TDecoded?> delete() => _deleteResponse(false).then((v) => v.value);
  Future<TDecoded?> tryDelete() => _deleteResponse(true).then((v) => v.value);

  KDeleteRequest<TDecoded> copyWith({
    String? Function(String)? pathTransform,
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParams,
    LogOptions? logOptions,
    bool? useBaseUrl,
    TDecoded Function(dynamic data, Response _)? decoder,
  }) => KDeleteRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    options: headers != null ? options : (options ?? this.options),
    cancelToken: cancelToken ?? this.cancelToken,
    queryParams: queryParams ?? this.queryParams,
    resolve: resolve,
    decoder: decoder ?? this.decoder,
    logOptions: logOptions ?? this.logOptions,
    useBaseUrl: useBaseUrl ?? this.useBaseUrl,
  );

  factory KDeleteRequest.from(
    KRestRequest<TDecoded> r, {
    FutureOr<KDeleteRequest<TDecoded>> Function(KDeleteRequest<TDecoded>)? resolve,
  }) => KDeleteRequest<TDecoded>(
    r._api,
    path: r.path,
    usePrimary: r.usePrimary,
    headers: r.headers,
    data: r.data,
    options: r.options,
    queryParams: r.queryParams,
    cancelToken: r.cancelToken,
    onReceiveProgress: r.onReceiveProgress,
    resolve: resolve,
    decoder: r.decoder,
    useBaseUrl: r.useBaseUrl,
    logOptions: r.logOptions,
  );
}

class KDownloadRequest<TDecoded> extends KRestRequest<TDecoded> {
  KDownloadRequest(
    super._api, {
    required super.path,
    required this.savePath,
    super.usePrimary,
    super.options,
    super.queryParams,
    super.cancelToken,
    super.onReceiveProgress,
    this.fileAccessMode = FileAccessMode.write,
    this.deleteOnError = true,
    this.lengthHeader = Headers.contentLengthHeader,
    super.logOptions,
    super.useBaseUrl,
    this.resolve,
  });

  static const method = 'DOWNLOAD';

  final dynamic savePath;
  final FileAccessMode fileAccessMode;
  final bool deleteOnError;
  final FutureOr<KDownloadRequest<TDecoded>> Function(KDownloadRequest<TDecoded>)? resolve;
  final String lengthHeader;

  Future<KResponse<dynamic, TDecoded>> _downloadResponse(bool tryRun) async {
    final r = resolve == null ? null : await resolve!(this);

    final response = _dio.download(
      r?.transformedPath ?? _transformedPath,
      savePath,
      options: r?.options ?? options,
      data: r?.data ?? data,
      fileAccessMode: fileAccessMode,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
      lengthHeader: r?.lengthHeader ?? lengthHeader,
      onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
      deleteOnError: deleteOnError,
    );
    return tryRun ? _tryRunRequest(method, response: response) : _runRequest(method, response: response);
  }

  Future<KResponse<dynamic, TDecoded>> downloadResponse() => _downloadResponse(false);
  Future<KResponse<dynamic, TDecoded>> tryDownloadResponse() => _downloadResponse(true);
  Future<void> download() => _downloadResponse(false).then((v) => v.value);
  Future<void> tryDownload() => _downloadResponse(true).then((v) => v.value);

  KDownloadRequest<TDecoded> copyWith({
    String? Function(String)? pathTransform,
    bool? usePrimary,
    dynamic savePath,
    Options? options,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    bool? deleteOnError,
    String? lengthHeader,
    FileAccessMode? fileAccessMode,
    LogOptions? logOptions,
    bool? useBaseUrl,
  }) => KDownloadRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    savePath: savePath ?? this.savePath,
    usePrimary: usePrimary ?? this.usePrimary,
    // options: headers != null ? options : (options ?? this.options),
    options: options ?? this.options,
    queryParams: queryParams ?? this.queryParams,
    cancelToken: cancelToken ?? this.cancelToken,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolve: resolve,
    deleteOnError: deleteOnError ?? this.deleteOnError,
    fileAccessMode: fileAccessMode ?? this.fileAccessMode,
    lengthHeader: lengthHeader ?? this.lengthHeader,
    logOptions: logOptions ?? this.logOptions,
    useBaseUrl: useBaseUrl ?? this.useBaseUrl,
  );

  factory KDownloadRequest.from(
    KRestRequest<TDecoded> r, {
    required dynamic savePath,
    String lengthHeader = Headers.contentLengthHeader,
    FutureOr<KDownloadRequest<TDecoded>> Function(KDownloadRequest<TDecoded>)? resolve,
  }) => KDownloadRequest<TDecoded>(
    r._api,
    path: r.path,
    usePrimary: r.usePrimary,
    savePath: savePath,
    options: r.options,
    queryParams: r.queryParams,
    cancelToken: r.cancelToken,
    onReceiveProgress: r.onReceiveProgress,
    resolve: resolve,
    lengthHeader: lengthHeader,
    useBaseUrl: r.useBaseUrl,
    logOptions: r.logOptions,
  );
}

class KRequest<TDecoded> extends KRestRequest<TDecoded> {
  KRequest(
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
    this.onSendProgress,
    super.logOptions,
    super.useBaseUrl,
    this.resolve,
  });

  static const method = 'REQUEST';

  final void Function(int, int)? onSendProgress;
  final FutureOr<KRequest<TDecoded>> Function(KRequest<TDecoded>)? resolve;

  Future<KResponse<Raw, TDecoded>> _request<Raw>(bool tryRun) async {
    final r = resolve == null ? null : await resolve!(this);

    final response = _dio.request<Raw>(
      r?.transformedPath ?? _transformedPath,
      options: r?.options ?? options,
      data: r?.data ?? data,
      queryParameters: r?.queryParams ?? queryParams,
      cancelToken: r?.cancelToken ?? cancelToken,
      onSendProgress: r?.onSendProgress ?? onSendProgress,
      onReceiveProgress: r?.onReceiveProgress ?? onReceiveProgress,
    );
    return tryRun ? _tryRunRequest(method, response: response) : _runRequest<Raw>(method, response: response);
  }

  Future<KResponse<Raw, TDecoded>> request<Raw>() => _request(false);
  Future<KResponse<Raw, TDecoded>> tryRequest<Raw>() => _request(true);
  Future<TDecoded?> get() => _request(false).then((v) => v.value);
  Future<TDecoded?> tryGet() => _request(true).then((v) => v.value);

  KRequest<TDecoded> copyWith({
    String? Function(String)? pathTransform,
    bool? usePrimary,
    Map<String, String>? headers,
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    LogOptions? logOptions,
    bool? useBaseUrl,
    TDecoded Function(dynamic data, Response _)? decoder,
  }) => KRequest<TDecoded>(
    _api,
    path: pathTransform?.call(path) ?? path,
    usePrimary: usePrimary ?? this.usePrimary,
    headers: headers ?? this.headers,
    data: data ?? this.data,
    queryParams: queryParams ?? this.queryParams,
    options: headers != null ? options : (options ?? this.options),
    cancelToken: cancelToken ?? this.cancelToken,
    onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
    resolve: resolve,
    decoder: decoder ?? this.decoder,
    logOptions: logOptions ?? this.logOptions,
    useBaseUrl: useBaseUrl ?? this.useBaseUrl,
  );

  factory KRequest.from(
    KRestRequest<TDecoded> r, {
    FutureOr<KRequest<TDecoded>> Function(KRequest<TDecoded>)? resolve,
  }) => KRequest<TDecoded>(
    r._api,
    path: r.path,
    usePrimary: r.usePrimary,
    headers: r.headers,
    data: r.data,
    options: r.options,
    queryParams: r.queryParams,
    cancelToken: r.cancelToken,
    onReceiveProgress: r.onReceiveProgress,
    resolve: resolve,
    decoder: r.decoder,
    useBaseUrl: r.useBaseUrl,
    logOptions: r.logOptions,
  );
}
