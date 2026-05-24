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
}
