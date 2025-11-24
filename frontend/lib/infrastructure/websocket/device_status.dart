import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../presentation/providers/websocket/device_status_provider.dart';
import 'main_websocket.dart';

void handleDeviceStatus(Ref ref, Map<String, dynamic> json) {
  final data = json['data'];
  if (data == null) return;

  if (data['status'] == 'stable'){
    ref.read(websocketStatusProvider.notifier).state = true;
  }
  else {
    ref.read(websocketStatusProvider.notifier).state = false;
  }
  ref.read(deviceStatusProvider.notifier).updateFromWs(data);
  logger.t("[WS] Device status updated: $data");
}
