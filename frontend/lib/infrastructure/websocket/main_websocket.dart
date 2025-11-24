import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/secure_storage.dart';
import 'enable_alarm.dart';
import 'pump_status.dart';
import 'device_status.dart';
import '../../core/utils/logger.dart';
import 'sensor_websocket.dart';

final websocketStatusProvider = StateProvider<bool>((ref) => false);

WebSocketChannel? _channel;
Timer? _reconnectTimer;
Timer? _pingTimer;
bool _connecting = false;
int _retryCount = 0;

final websocketUrl = dotenv.env['WEBSOCKET_URL'];

Future<void> initWebsocket(Ref ref) async {
  final deviceId = await SecureStorage.getDeviceId();

  if (deviceId == null || deviceId.isEmpty) {
    logger.w("[WS] No device ID found — skipping connection");
    return;
  }

  if (_channel != null || _connecting) return;

  _connecting = true;
  logger.i("[WS] Connecting to $websocketUrl");

  try {
    _channel = WebSocketChannel.connect(Uri.parse('$websocketUrl'));
    _connecting = false;
    _retryCount = 0;

    logger.i("[WS] Connected ✅");

    _startPing(ref);
    _listen(ref);
  } catch (e) {
    _connecting = false;
    ref.read(websocketStatusProvider.notifier).state = false;
    logger.e("[WS] Failed to connect: $e");
    _scheduleReconnect(ref);
  }
}

void _listen(Ref ref) {
  _channel?.stream.listen(
    (msg) async {
      try {
        final json = jsonDecode(msg);
        final type = json['type'];
        final payloadDeviceId = json['device_id'];
        final currentDeviceId = await SecureStorage.getDeviceId();

        if (payloadDeviceId != null && payloadDeviceId != currentDeviceId) {
          logger.t("[WS] Ignored message for other device: $payloadDeviceId");
          return;
        }

        switch (type) {
          case 'sensor':
            handleSensor(ref, json);
            break;
          case 'pump_status':
            handlePumpStatus(ref, json);
            break;
          case 'device_status':
            handleDeviceStatus(ref, json);
            break;
          case 'update_enabled':
            handleUpdateEnabled(ref, json);
            break;
          default:
            logger.w("[WS] Unknown type: $type");
        }
      } catch (e) {
        ref.read(websocketStatusProvider.notifier).state = false;
        logger.e("[WS] Parse error: $e");
      }
    },
    onError: (err) {
      logger.e("[WS] Error: $err");
      ref.read(websocketStatusProvider.notifier).state = false;
      _scheduleReconnect(ref);
    },
    onDone: () {
      logger.w("[WS] Connection closed");
      ref.read(websocketStatusProvider.notifier).state = false;
      _scheduleReconnect(ref);
    },
  );
}


void _scheduleReconnect(Ref ref) {
  _stopPing();

  ref.read(websocketStatusProvider.notifier).state = false;

  if (_reconnectTimer?.isActive ?? false) return;

  _retryCount++;
  final delay = Duration(seconds: (2 << (_retryCount - 1)).clamp(1, 5));
  logger.w("[WS] Reconnecting in ${delay.inSeconds}s...");

  _reconnectTimer = Timer(delay, () async {
    _channel?.sink.close(1000);
    _channel = null;
    await initWebsocket(ref);
  });
}

void _startPing(Ref ref) async {
  _pingTimer?.cancel();

  _pingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
    try {
      logger.i("[WS] PING To Backend");
    } catch (_) {}
  });
}

void _stopPing() {
  _pingTimer?.cancel();
  _pingTimer = null;
}

Future<void> closeWebsocket(Ref ref) async {
  await _channel?.sink.close(status.goingAway);
  _stopPing();
  _reconnectTimer?.cancel();
  _channel = null;
  ref.read(websocketStatusProvider.notifier).state = false;
  logger.i("[WS] Closed manually");
}
