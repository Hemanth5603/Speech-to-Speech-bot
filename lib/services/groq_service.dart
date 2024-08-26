import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:groq/groq.dart';  // Import the Groq package

import 'package:tensorgo_speech_chatbot/models/model_response.dart';

// Define your Groq API key and endpoint
const String apiKey = "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";
const String apiEndpoint = "http://192.168.29.219:5000/chat";  // Replace with your server's endpoint

class GroqService extends GetxController {
  ModelResponse modelResponse = ModelResponse(response: "");
  final FlutterTts _flutterTts = FlutterTts();
  final RxString result = "".obs;  // Observable string

  final _groq = Groq(
    apiKey: apiKey,
    model: GroqModel.gemma2_9b_it, // Set a different model
  );

  @override
  void onInit() {
    super.onInit();
    _groq.startChat();
  }

  void sendMessage(String text) async {
    try {
      GroqResponse response = await _groq.sendMessage(text);
      result.value = response.choices.first.message.content;
      print(result.value);
      speak(result.value);
    } on GroqException catch (error) {
      print("Error Occurred $error");
    }
  }

  void stop() async {
    print("Stop Called");
    await _flutterTts.stop();  // Use the `stop` method to immediately halt the speech
  }

  void speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setVoice({"name": "Karen", "locale": "en-AU"});
    await _flutterTts.setSpeechRate(0.5); // Adjust the speech rate if needed
    await _flutterTts.speak(text);  // Use the `text` parameter instead of `result.value`
  }
}
