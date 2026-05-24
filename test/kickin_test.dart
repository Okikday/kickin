import 'package:flutter_test/flutter_test.dart';
import 'package:kickin/kickin.dart';
import 'package:dio/dio.dart';

class TestApi extends KRestApiBase {
  TestApi() {
    intialize(baseUrl: 'https://api.kickin.dev', monitorActivities: false);
    setPrimaryDio(Dio());
  }

  late final users = UsersApi(this);
}

class UsersApi extends KRestApi<Map<String, dynamic>> {
  UsersApi(super.parent);

  late final getUser = KGetRequest(this, path: '/users', decoder: (data, _) => data);

  late final getUserAbsolute = KGetRequest(
    this,
    path: 'https://other-api.dev/users',
    useBaseUrl: false,
    decoder: (data, _) => data,
  );
}

void main() async {
  group('Network module tests', () {
    late TestApi api;

    setUp(() {
      api = TestApi();
    });

    test('KRestRequest appends base URL properly when useBaseUrl is true (default)', () {
      final request = api.users.getUser;
      expect(request.transformedPath, 'https://api.kickin.dev/users');
    });

    test('KRestRequest ignores base URL when useBaseUrl is false', () {
      final request = api.users.getUserAbsolute;
      expect(request.transformedPath, 'https://other-api.dev/users');
    });

    test('KRestApi subclasses inherit id correctly based on parent and runtimeType', () {
      expect(api.users.id, 'TestApi_UsersApi');
    });
  });

  group('KResult utility tests', () {
    test('KResult tryRun captures success', () {
      final result = KResult.tryRun(() => 'success');

      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
      expect(result.data, 'success');
    });

    test('KResult tryRun captures failure', () {
      final result = KResult.tryRun(() {
        throw Exception('failure');
      }, logError: false);

      expect(result.isError, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.message, 'Exception: failure');
    });

    test('KResult tryRunAsync captures async success', () async {
      final result = await KResult.tryRunAsync(() async => 'async success');

      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
      expect(result.data, 'async success');
    });

    test('KResult tryRunAsync captures async failure', () async {
      final result = await KResult.tryRunAsync(() async {
        throw Exception('async failure');
      }, logError: false);

      expect(result.isError, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.message, 'Exception: async failure');
    });
  });
}
