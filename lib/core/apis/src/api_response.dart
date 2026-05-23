import 'package:dio/dio.dart';

class KResponse<Raw, Formatted> extends Response<Raw> {
  final Formatted Function(Raw)? decoder;
  final Object? error;
  KResponse({this.decoder, this.error, required super.requestOptions});

  bool get isSuccess => data != null;
  Raw? get raw => data;

  Formatted? get formatted => value;

  /// Don't call this if you didn't provide a [decoder] function, otherwise it would return null;
  Formatted? get value {
    final data = this.data;
    if (data == null || decoder == null) return null;
    try {
      return decoder?.call(data);
    } catch (e) {
      return null;
    }
  }
}
