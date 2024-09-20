import 'dart:developer';

import 'package:example/src/core/utils/api_keys.dart';
import 'package:groq_sdk/groq_sdk.dart';

class GroqService {
  GroqService() {
    groqChat = groq.startNewChat(GroqModels.llama3_8b,
        settings: const GroqChatSettings.defaults()
            .copyWith(choicesCount: 1, maxTokens: 128, stream: false));
  }
  GroqChat? groqChat;
  final groq = Groq(
    ApiKeys.groqApiKey,
  );

  Future<GroqAnswer> sendMsg(
      {String text = "Hello, How are you?", required String name}) async {
    //Creating a new chat

    //Listening to chat events
    groqChat?.stream.listen((event) {
      event.when(request: (requestEvent) {
        log('Request sent...');
        // print(requestEvent.message.content);
      }, response: (responseEvent) {
        log('Received response: ${responseEvent.response.choices.first.message}');
      });
    });
    try {
      //Sending a message which will add new data to the listening stream
      final (response, usage) = await groqChat!.sendMessage(
          "You are a helpful and friendly AI assistant named $name. Respond like a human with clear, specific answers. Keep responses under 120 characters."
          "User Question: $text"
          "Max answer length: 120 characters");
      return GroqAnswer.successful(response.choices.first.message);
    } on GroqException catch (error) {
      return GroqAnswer.failed(error.error.message);
    }
  }
}

class GroqAnswer {
  final bool isSuccessFull;
  final String data;

  GroqAnswer({
    required this.isSuccessFull,
    required this.data,
  });

  factory GroqAnswer.fromJson(Map<String, dynamic> json) => GroqAnswer(
        isSuccessFull: json["isSuccessFull"],
        data: json["data"],
      );
  factory GroqAnswer.successful(String data) => GroqAnswer(
        isSuccessFull: true,
        data: data,
      );
  factory GroqAnswer.failed(String data) => GroqAnswer(
        isSuccessFull: false,
        data: data,
      );

  Map<String, dynamic> toJson() => {
        "isSuccessFull": isSuccessFull,
        "data": data,
      };
}
