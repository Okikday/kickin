import 'package:dio/dio.dart';

class KApiResponse<In, Out> {
  final In? raw;

  final Out Function(In?)? transform;
  KApiResponse({required this.raw, this.transform});

  bool get isSuccess => raw != null;

  Out? get data {
    if (isSuccess) {
      return transform != null ? transform!(raw as In) : raw as Out?;
    }
    return null;
  }

  static Future<KApiResponse<In, Out>> run<In, Out>(
    Future<In> Function(Dio dio) operation, {
    Out Function(In?)? transform,
  }) async {
    try {
      final raw = await operation(Dio());
      return KApiResponse<In, Out>(raw: raw, transform: transform);
    } catch (e) {
      return KApiResponse<In, Out>(raw: null, transform: transform);
    }
  }
}
