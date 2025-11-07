import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

typedef OnSensorEvent = void Function(Map<String, dynamic> event);

class WebsocketService {
  WebSocketChannel? _channel;
  final Map<String, OnSensorEvent> _handlers = {};

  bool _isConnecting = false;
  bool _disposed = false;
  int _retryAttempt = 0;

  Timer? _reconnectTimer;
  Timer? _pingTimer;

  String? url = dotenv.env['WEBSOCKET_URL'];

  WebsocketService();

  /// Getter untuk status koneksi
  bool get isConnected => _channel != null && !_isConnecting;

  /// Connect WebSocket (otomatis jika belum)
  void connect() {
    if (_isConnecting || _disposed || _channel != null) return;

    _isConnecting = true;
    logger.i("[WS] Connecting to $url ...");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url!));
      _isConnecting = false;
      _retryAttempt = 0;

      logger.i("[WS] Connected ✅");

      _startPing();
      _listenGlobal();
      _restoreHandlers();
    } catch (e) {
      logger.e("[WS] Connection failed: $e");
      _isConnecting = false;
      _scheduleReconnect();
    }
  }

  /// Listener global — hanya satu stream aktif
  void _listenGlobal() {
    _channel?.stream.listen(
      (msg) {

        try {
          final json = (msg is String) ? jsonDecode(msg) : msg;
          if (json is Map<String, dynamic>) {
            final msgDeviceId = json['device_id']?.toString();
            final handler = _handlers[msgDeviceId];
            if (handler != null) {
              final data =
                  (json['data'] is Map<String, dynamic>) ? json['data'] : json;
              handler(Map<String, dynamic>.from(data));
            }
          }
        } catch (e) {
          logger.e("[WS] Parse error: $e");
        }
      },
      onError: (err) {
        logger.e("[WS] Stream error: $err");
        _scheduleReconnect();
      },
      onDone: () {
        logger.w("[WS] Disconnected");
        _scheduleReconnect();
      },
      cancelOnError: true,
    );
  }

  /// Daftarkan listener untuk 1 device
  void listen(String deviceId, OnSensorEvent onEvent) {
    _handlers[deviceId] = onEvent;
    connect();
    logger.i("[WS] Listening to device: $deviceId");
  }

  /// Hentikan listener 1 device
  void stopListening(String deviceId) {
    _handlers.remove(deviceId);
    logger.i("[WS] Stopped listening to $deviceId");
  }

  /// Kembalikan semua handler setelah reconnect
  void _restoreHandlers() {
    if (_handlers.isEmpty) return;
    logger.i("[WS] Restoring listeners: ${_handlers.keys.join(', ')}");
  }

  /// Jadwalkan reconnect otomatis (exponential backoff)
  void _scheduleReconnect() {
    if (_disposed) return;
    if (_reconnectTimer?.isActive ?? false) return;

    _stopPing();
    _retryAttempt++;
    final delay = Duration(seconds: (2 << (_retryAttempt - 1)).clamp(1, 30));

    logger.w("[WS] Reconnecting in ${delay.inSeconds}s...");

    _reconnectTimer = Timer(delay, () async {
      await _closeChannel();
      connect();
    });
  }

  /// Kirim heartbeat tiap 30 detik agar koneksi tetap hidup
  void _startPing() {
    _stopPing();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      try {
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
        logger.t("[WS] Ping sent");
      } catch (_) {}
    });
  }

  void _stopPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// Tutup channel dengan aman
  Future<void> _closeChannel() async {
    try {
      await _channel?.sink.close(status.goingAway);
    } catch (_) {}
    _channel = null;
  }

  /// Tutup semua koneksi & hentikan auto reconnect
  Future<void> dispose() async {
    _disposed = true;
    _stopPing();
    _reconnectTimer?.cancel();
    _handlers.clear();

    await _closeChannel();
    logger.i("[WS] Disposed completely");
  }
}
