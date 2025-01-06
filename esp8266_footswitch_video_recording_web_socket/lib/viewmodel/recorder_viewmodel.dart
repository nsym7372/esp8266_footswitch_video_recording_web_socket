import 'dart:async';

import 'package:camera/camera.dart';
import 'package:video_recording/model/camera_service.dart';
import 'package:video_recording/model/websocket_service.dart';

class RecorderViewModel {
  final CameraService cameraService;
  final WebSocketService webSocketService;

  final StreamController<bool> _recordingController =
      StreamController<bool>.broadcast();
  Stream<bool> get isRecordingStream => _recordingController.stream;

  final StreamController<String> _serverMessageController =
      StreamController<String>.broadcast();
  Stream<String> get serverMessage => _serverMessageController.stream;

  CameraController get cameraController => cameraService.cameraController;

  RecorderViewModel(this.cameraService, this.webSocketService) {
    webSocketService.messages.listen(_handleWebSocketMessage);
  }

  bool _isRecording = false;

  void _handleWebSocketMessage(String message) async {
    if (message != "PRESSED") {
      return;
    }

    if (!_isRecording) {
      await cameraService.startRecording();
    } else {
      await cameraService.stopRecording('/storage/emulated/0/Movies');
    }

    _recordingController.add(!_isRecording);
    _isRecording = !_isRecording;
  }

  void dispose() {
    webSocketService.close();
    _recordingController.close();
    _serverMessageController.close();
  }
}
