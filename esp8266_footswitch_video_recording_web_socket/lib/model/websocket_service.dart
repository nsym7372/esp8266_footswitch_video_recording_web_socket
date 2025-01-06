import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final WebSocketChannel _channel;

  WebSocketService._(this._channel);

  factory WebSocketService(String url) {
    final channel = WebSocketChannel.connect(Uri.parse(url));
    return WebSocketService._(channel);
  }

  Stream<String> get messages => _channel.stream.cast<String>();

  void close() {
    _channel.sink.close();
  }
}
