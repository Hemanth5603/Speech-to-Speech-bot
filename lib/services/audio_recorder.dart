import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoiceRecorder extends GetxController{
    RxBool isRecording = false.obs;
    late final AudioRecorder _audioRecorder;
    RxString audiopath = "".obs;

    @override
  void onInit() {
    
    super.onInit();
    _audioRecorder = AudioRecorder();
  }


  @override
  void onClose() {
    
    super.onClose();
    _audioRecorder.dispose();
  }


  String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
      5,
      (index) => chars[random.nextInt(chars.length)],
      growable: false,
    ).join();
  }

   Future<void> _startRecording() async {
    try {
      debugPrint(
          '=========>>>>>>>>>>> RECORDING!!!!!!!!!!!!!!! <<<<<<===========');

      String filePath = await getApplicationDocumentsDirectory()
          .then((value) => '${value.path}/audio.wav');

      await _audioRecorder.start(
        const RecordConfig(
          // specify the codec to be `.wav`
          encoder: AudioEncoder.wav,
        ),
        path: filePath,
      );
    } catch (e) {
      debugPrint('ERROR WHILE RECORDING: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      String? path = await _audioRecorder.stop();

  
      audiopath.value = path!;
      
      debugPrint('=========>>>>>> PATH: $audiopath <<<<<<===========');
    } catch (e) {
      debugPrint('ERROR WHILE STOP RECORDING: $e');
    }
  }

  void record() async {
    if (isRecording.value == false) {
      final status = await Permission.microphone.request();

      if (status == PermissionStatus.granted) {
       
          isRecording.value = true;
        
        await _startRecording();
      } else if (status == PermissionStatus.permanentlyDenied) {
        debugPrint('Permission permanently denied');
      }
    } else {
      await _stopRecording();
      uploadAudio(audiopath.value);
      isRecording.value = false;
    }
  }


   Future<void> uploadAudio(String filePath) async {
    final uri = Uri.parse('https://speech-to-speech-tensorgo.onrender.com/stt');
    final file = File(filePath);
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile(
          'file',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: filePath,
          contentType: MediaType('audio', 'wav'),
        ),
      );

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      print(responseBody.body);
      print('Upload successful');
      
    } else {
      print('Upload failed: ${response.statusCode}');
    }
  }
}