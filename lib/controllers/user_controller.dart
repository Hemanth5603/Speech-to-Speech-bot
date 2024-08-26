import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tensorgo_speech_chatbot/models/model_response.dart';


class UserController extends GetxController{
  final FlutterTts _flutterTts = FlutterTts();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController userInput = TextEditingController();
  var isLoading = false.obs;
  RxString result = "".obs;
  ModelResponse modelResponse = ModelResponse(response: "");
  TextEditingController url = TextEditingController();

Future<void> generateResponse() async {
  final uri = Uri.parse("https://speech-to-speech-tensorgo.onrender.com/chat");

  print(userInput.text.toString());

  Map<String, String> request = {
    "message": userInput.text.toString(),
  };

  try {
    var response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},  // Add this line
      body: jsonEncode(request),  // Convert the request to JSON
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());
      modelResponse = ModelResponse.fromJson(data);
      result.value = modelResponse.response;
      print(modelResponse.response);
      speak(result.value);
    } else {
      print("Error fetching data: ${response.statusCode}");
      Get.snackbar("Error", "Cannot Get Response");
    }
  } catch (e) {
    print("Error: $e");
    Get.snackbar("Error", "Connection failed. Please check your network.");
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


