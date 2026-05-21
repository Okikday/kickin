import 'dart:developer';

import 'package:kickin/core/apis/api_base.dart';

class Apis extends KApiBase {
  static final instance = Apis();

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

void main() {}
