import 'package:dio/dio.dart';
import 'package:kickin/core/apis/api_base.dart';

class KResponse<Raw, Formatted> extends Response<Raw> {
  final Decoder<Raw, Formatted>? decoder;
  final Object? error;
  KResponse({this.decoder, this.error, required super.requestOptions});

  bool get isSuccess => data != null;

  /// Don't call this if you didn't provide a [decoder] function, otherwise it would return null;
  Formatted? get value {
    final data = this.data;
    if (data == null || decoder == null) return null;
    try {
      return decoder!(data);
    } catch (e) {
      return null;
    }
  }
}
