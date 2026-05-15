library;

import 'package:flutter/foundation.dart';
import 'package:kickin/core/apis/api_base.dart';

export 'package:kickin/core/apis/api_base.dart';

enum ApiKeys implements ApiKeyEnum { openAi, googleMaps }

final _apiKeys = {ApiKeys.openAi: 'your-openai-api-key', ApiKeys.googleMaps: 'your-google-maps-api-key'};

void main() async {
  await AppApi.instance.intialize(withApiKeys: _apiKeys);
  AppApi.instance.chat.sendMessage("Hello, OpenAI!");
}

class AppApi extends ApiBase {
  AppApi._();
  static final instance = AppApi._();

  final chat = ChatApi();
}

class ChatApi extends Api {
  const ChatApi();

  void sendMessage(String message) {
    final apiKey = ApiKeys.openAi.key;
    // Use the apiKey to send a message to the OpenAI API
    if (kDebugMode) {
      print("Sending message: '$message' using API, key: $apiKey");
    }
  }
}
