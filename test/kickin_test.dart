import 'dart:developer';

import 'package:kickin/core/apis/api_base.dart';

class Apis extends KApiBase {
  static final find = Apis();

  late final chats = ChatsApi(this); // ChatsApi extends ApiInterface
}

class ChatsApi extends KApi<Map> {
  ChatsApi(super._parent);

  late final tasks = KPostRequest(
    this,
    path: '/chats',
    decoder: (data, r) => r.data,
    resolve: (request) async => request.copyWith(),
  );

  late final restTest = KRestRequest(this, path: '');
  late final restTest2 = KGetRequest.from(restTest, resolve: (p0) => p0.copyWith());
  late final postTest = KPostRequest(this, path: '', resolve: (r) => r.copyWith());

  Future<String> fetchData() async {
    log(cache.toString());
    log(baseUrl);

    // Implement API call logic here, using _baseUrl and _apiKeys as needed.
    return 'Chat data';
  }
}

mixin ChatsApiRequests on ChatsApi {}

class ChatModel {}

void main() {}
