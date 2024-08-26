import 'package:flutter/material.dart';
import 'package:tensorgo_speech_chatbot/speech.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromARGB(255,35,37,49),
        body: Speech()
      ),
    );
  }
}
