import 'package:flutter/material.dart';

import 'package:video_recording/model/camera_service.dart';
import 'package:video_recording/model/websocket_service.dart';
import 'package:video_recording/view/recorder_view.dart';
import 'package:video_recording/viewmodel/recorder_viewmodel.dart';

import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<CameraDescription> cameras = await availableCameras();
  final cameraController =
      CameraController(cameras.first, ResolutionPreset.low);
  await cameraController.initialize();

  final cameraService = CameraService(cameraController);
  final webSocketService = WebSocketService("ws://192.168.179.10:81");
  final viewModel = RecorderViewModel(cameraService, webSocketService);

  runApp(MyApp(viewModel: viewModel));
}

class MyApp extends StatelessWidget {
  final RecorderViewModel viewModel;
  const MyApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RecorderView(viewModel: viewModel),
    );
  }
}
