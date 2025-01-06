import 'package:flutter/material.dart';

import 'package:video_recording/viewmodel/recorder_viewmodel.dart';
import 'package:camera/camera.dart'; // カメラ操作のため

class RecorderView extends StatelessWidget {
  final RecorderViewModel viewModel;

  RecorderView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: viewModel.isRecordingStream,
        initialData: false,
        builder: (context, snapshot) {
          final isRecording = snapshot.data ?? false;

          return Scaffold(
              backgroundColor: isRecording ? Colors.red.shade100 : null,
              appBar: AppBar(
                title: const Text('recorder',
                    style: TextStyle(fontSize: 16, color: Colors.black)),
                toolbarHeight: 40.0,
                backgroundColor: isRecording ? Colors.red.shade100 : null,
              ),
              body: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  constraints: const BoxConstraints(minHeight: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 8,
                          child: StreamBuilder<String>(
                            stream: viewModel.serverMessage,
                            initialData: "Waiting for data...",
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? "Waiting for data...",
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          )),
                      Expanded(
                        flex: 2,
                        child: Text(
                          isRecording ? "録画中…" : "待機中…",
                          style: TextStyle(
                            fontSize: 12,
                            color: isRecording ? Colors.red : Colors.green,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  ),
                ),
                if (viewModel.cameraController.value.isInitialized)
                  Flexible(
                    child: AspectRatio(
                        aspectRatio:
                            viewModel.cameraController.value.aspectRatio,
                        child: CameraPreview(viewModel.cameraController)),
                  ),
              ]));
        });
  }
}
