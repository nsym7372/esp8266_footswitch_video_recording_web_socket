import 'dart:io';
import 'dart:developer';

import 'package:camera/camera.dart';

class CameraService {
  final CameraController _cameraController;
  CameraService(this._cameraController);

  CameraController get cameraController => _cameraController;

  Future<void> startRecording() async {
    if (!_cameraController.value.isInitialized) {
      return;
    }

    try {
      await _cameraController.startVideoRecording();
    } catch (e) {
      log("動画撮影の開始に失敗しました: $e");
    }
  }

  Future<String?> stopRecording(String directory) async {
    if (!_cameraController.value.isInitialized) {
      null;
    }

    try {
      final file = await _cameraController.stopVideoRecording();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$directory/video_$timestamp.mp4';

      // 一時ファイルを指定ディレクトリに移動
      await File(file.path).copy(filePath);
      await File(file.path).delete();

      return filePath;
    } catch (e) {
      log("動画撮影の終了に失敗しました: $e");
      return null;
    }
  }
}
