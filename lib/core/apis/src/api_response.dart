import 'package:dio/dio.dart';

class KResponse<In, Out> extends Response<In> {
  final Out Function(In?)? decode;
  KResponse({this.decode, required super.requestOptions});

  bool get isSuccess => data != null;

  Out? get value => decode != null ? decode!(data) : data as Out?;
}
