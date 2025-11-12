import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../presentation/providers/websocket/sensor_provider.dart';

Future<void> handleSensor(Ref ref, Map<String, dynamic> json) async {
  final data = json['data'];
  if (data == null) return;

  ref.read(sensorProvider.notifier).updateFromWs(data);

  logger.t("[WS] Sensor updated: $data");
}
