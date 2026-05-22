import 'package:dio/dio.dart';

class KResponse<In, Out> extends Response<In> {
  final Out Function(In?)? transform;
  KResponse({this.transform, required super.requestOptions});

  bool get isSuccess => data != null;

  Out? get value => transform != null ? transform!(data) : data as Out?;
}
