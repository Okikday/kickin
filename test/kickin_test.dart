import 'dart:developer';

import 'package:kickin/core/apis/api_base.dart';

class Apis extends KApiBase {
  static final find = Apis();

  late final chats = ChatsApi(this); // ChatsApi extends ApiInterface
}

class ChatsApi extends KApi<Map> {
  ChatsApi(super._parent);

  Future<String> fetchData() async {
    log(cache.toString());
    log(baseUrl);

    // Implement API call logic here, using _baseUrl and _apiKeys as needed.
    return 'Chat data';
  }
}

mixin ChatsApiRequests on ChatsApi {
  late final tasks = KPostRequest(
    this,
    path: '/chats',
    decoder: (data, r) => r.data,
    resolveRequest: (request) async => request.copyWith(),
  );
}

class ChatModel {}

void main() {}
