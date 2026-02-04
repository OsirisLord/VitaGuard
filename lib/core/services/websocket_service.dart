import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../errors/exceptions.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<dynamic>? _streamController;
  Timer? _reconnectTimer;
  bool _isConnected = false;

  // Default ESP32 WebSocket URL (often just IP:81 or similar)
  // Configurable for production
  String _currentUrl = 'ws://192.168.4.1:81';

  Stream<dynamic> get stream {
    if (_streamController == null) {
      _streamController = StreamController<dynamic>.broadcast(
        onListen: () => _connect(_currentUrl),
        onCancel: disconnect,
      );
    }
    return _streamController!.stream;
  }

  bool get isConnected => _isConnected;

  void connect(String url) {
    _currentUrl = url;
    _connect(url);
  }

  void _connect(String url) {
    if (_isConnected) return;

    try {
      print('Connecting to WebSocket: $url');
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;

      _channel!.stream.listen(
        (data) {
          if (_streamController != null && !_streamController!.isClosed) {
            _streamController!.add(data);
          }
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _reconnect();
        },
        onDone: () {
          print('WebSocket Disconnected');
          _isConnected = false;
          _reconnect();
        },
      );
    } catch (e) {
      print('WebSocket Connection Failed: $e');
      _reconnect();
    }
  }

  void _reconnect() {
    _isConnected = false;
    _channel?.sink.close();

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (_streamController != null && !_streamController!.isClosed) {
        print('Attempting to reconnect...');
        _connect(_currentUrl);
      }
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    // Don't close stream controller here as we might want to listen again
  }

  void send(String data) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(data);
    } else {
      throw const ServerException(message: 'WebSocket not connected');
    }
  }

  /// Helper to parse typical JSON data from ESP32
  /// Expected format: {"spo2": 98, "bpm": 72, "temp": 37.0}
  Map<String, dynamic>? parseData(String data) {
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      print('Failed to parse WebSocket data: $e');
      return null;
    }
  }
}
