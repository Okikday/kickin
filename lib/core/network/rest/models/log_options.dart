class LogOptions {
  final bool queryParams;
  final bool responseData;
  final bool requestData;
  final bool headers;
  final int maxLogLength;

  const LogOptions({
    this.queryParams = true,
    this.responseData = false,
    this.requestData = false,
    this.headers = false,
    this.maxLogLength = 1024,
  });

  factory LogOptions.debugAll() =>
      const LogOptions(queryParams: true, responseData: true, requestData: true, headers: true);

  factory LogOptions.debugResponse() =>
      const LogOptions(queryParams: false, responseData: true, requestData: false, headers: false);

  factory LogOptions.debugRequest() =>
      const LogOptions(queryParams: true, responseData: false, requestData: true, headers: true);
}
