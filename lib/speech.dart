import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:tensorgo_speech_chatbot/controllers/user_controller.dart';
import 'package:tensorgo_speech_chatbot/services/groq_service.dart';
import 'package:text_gradiate/text_gradiate.dart';

class Speech extends StatefulWidget {
  const Speech({super.key});

  @override
  State<Speech> createState() => _SpeechState();
}

class _SpeechState extends State<Speech> {
  final UserController userController = Get.put(UserController());
  final GroqService groqService = Get.put(GroqService());
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    userController.userInput.text = "";
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    print("Speech recognition initialized: $_speechEnabled"); 
    setState(() {});
  }

  void _startListening() async {
    userController.stop();
    if (_speechEnabled) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {
        isListening = true;
      });
    } else {
      print("Speech recognition is not initialized");
      // Optionally, show a message to the user here
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      isListening = false;
    });
    
    // Print the recognized text
    print("Final recognized text: ${userController.userInput.text.toString()}");

    // Call the Groq service to send the message and generate the response
    //groqService.sendMessage(userController.userInput.text.toString());
    userController.generateResponse();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
  setState(() {
    userController.userInput.text = result.recognizedWords;
  });
  print("Recognized words: ${userController.userInput.text}");

  // Check if the final result is provided (or if confidence is high)
  if (result.finalResult) {
    _stopListening();
  }
}

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 35, 37, 49),
      
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 150,
              padding: EdgeInsets.all(15),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextGradiate(
                    text: Text(
                      'Hello',
                      style: TextStyle(fontSize: 50.0, fontFamily: 'man-sb'),
                    ),
                    colors: [Color.fromARGB(255, 143, 205, 255),Color.fromARGB(255, 240, 154, 255), Color.fromARGB(255, 255, 150, 142)],
                    gradientType: GradientType.linear,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    tileMode: TileMode.clamp,
                  ),
                  Text(
                      'Lets have a quick chat !!',
                      style: TextStyle(fontSize: 30.0, fontFamily: 'man-r', color: Colors.white),
                    ),
                ],
              )
            ),
            Container(
              width: w,
              height: 110,
              padding: const EdgeInsets.only(left:20, top:20, right: 20, bottom: 0),
              child: Text(
                userController.userInput.text.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'man-sb',
                  fontSize: 30
                ),
              ),
            ),
            Obx(() =>
              Container(
                width: MediaQuery.of(context).size.width,
                height: 450,
                padding:const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Text(userController.result.value.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'man-r',
                      fontSize: 18,
                      
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: const Color.fromARGB(60, 255, 255, 255),
                ),
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      isListening ? Icons.mic : Icons.mic_off,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      size: 30,
                    ),
                    onPressed: () {
                      if (_speechEnabled) {
                        setState(() {
                          print("Speech recognition button pressed");
                          _speechToText.isNotListening ? _startListening() : _stopListening();
                          userController.userInput.text = "";
                        });
                      } else {
                        print("Speech recognition is not ready yet");
                        // Optionally, show a message to the user here
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
