import 'package:dio/dio.dart';

class KResponse<Out> extends Response<Out> {
  final Out Function(Object?)? decode;
  final Object? error;
  KResponse({this.decode, this.error, required super.requestOptions});

  bool get isSuccess => data != null;

  Out? get value => decode != null ? decode!(data) : data;
}
