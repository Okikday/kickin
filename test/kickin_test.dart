import 'dart:developer';

import 'package:kickin/core/apis/api_base.dart';

class Apis extends KApiBase {
  static final find = Apis();

  late final chats = ChatsApi(this); // ChatsApi extends ApiInterface
}

class ChatsApi extends KApi {
  ChatsApi(super._parent);

  Future<String> fetchData() async {
    log(cache.toString());
    log(baseUrl);

    // Implement API call logic here, using _baseUrl and _apiKeys as needed.
    return 'Chat data';
  }
}

mixin ChatsApiRequests on ChatsApi {
  final tasks = KPostRequest(
    '/chats',
    decoder: (p0) => ChatModel(),
    resolveRequest: (request) async => request.copyWith(),
  );
}

class ChatModel {}

void main() {}
