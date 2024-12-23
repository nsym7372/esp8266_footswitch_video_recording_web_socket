import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:camera/camera.dart'; // カメラ操作のため
import 'package:permission_handler/permission_handler.dart';

late List<CameraDescription> cameras; // グローバルに定義

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // 利用可能なカメラを取得
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WebSocketDemo(),
    );
  }
}

class WebSocketDemo extends StatefulWidget {
  const WebSocketDemo({super.key});
  @override
  WebSocketDemoState createState() => WebSocketDemoState();
}

class WebSocketDemoState extends State<WebSocketDemo> {
  late WebSocketChannel channel;
  String serverMessage = "Waiting for data...";
  late CameraController cameraController;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();

    // ESP32のWebSocketサーバーに接続
    channel = IOWebSocketChannel.connect("ws://192.168.179.10:81");
    channel.stream.listen((message) {
      setState(() {
        serverMessage = message; // メッセージを表示するために状態を更新
      });

      if (!cameraController.value.isRecordingVideo) {
        // 最初のメッセージで動画撮影を開始
        startRecording();
      } else {
        // 次のメッセージで動画撮影を終了
        stopRecording();
      }
    });

    // カメラコントローラを初期化
    cameraController = CameraController(
      cameras.first,
      ResolutionPreset.low,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    cameraController.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });

    requestPermissions();
    WakelockPlus.enable();
  }

  Future<void> requestPermissions() async {
    await Permission.storage.request();
    if (await Permission.storage.isDenied) {
      throw Exception("ストレージへのアクセス権限が必要です");
    }
  }

  Future<void> startRecording() async {
    if (!cameraController.value.isInitialized) return;

    try {
      await cameraController.startVideoRecording();
      setState(() {
        isRecording = cameraController.value.isRecordingVideo;
      });
    } catch (e) {
      print("動画撮影の開始に失敗しました: $e");
    }
  }

  Future<void> stopRecording() async {
    if (!cameraController.value.isRecordingVideo) return;

    try {
      final file = await cameraController.stopVideoRecording();

      // 保存先ディレクトリを設定
      const directory = '/storage/emulated/0/Movies'; // Androidの「動画」フォルダ
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$directory/video_$timestamp.mp4';

      // 一時ファイルを指定ディレクトリに移動
      final savedFile = await File(file.path).copy(filePath);

      // ギャラリーに登録
      await registerToGallery(savedFile.path);

      // 一時ファイルを削除
      await File(file.path).delete();

      setState(() {
        serverMessage = "動画が保存されました: $savedFile";
        isRecording = cameraController.value.isRecordingVideo;
      });
    } catch (e) {
      print("動画撮影の終了に失敗しました: $e");
    }
  }

  Future<void> registerToGallery(String filePath) async {
    const platform = MethodChannel('com.example.app/media');
    try {
      await platform
          .invokeMethod('registerVideoToGallery', {'filePath': filePath});
      print("ギャラリーへの登録が完了しました: $filePath");
    } catch (e) {
      print("ギャラリー登録エラー: $e");
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    channel.sink.close();
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Demo'),
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          serverMessage,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 20),
        isRecording
            ? const Text(
                "録画中...",
                style: TextStyle(color: Colors.red, fontSize: 20),
              )
            : const Text(
                "待機中...",
                style: TextStyle(color: Colors.green, fontSize: 20),
              ),
      ])),
    );
  }
}
