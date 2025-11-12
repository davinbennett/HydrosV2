import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../presentation/providers/websocket/pump_status_provider.dart';

void handlePumpStatus(Ref ref, Map<String, dynamic> json) {
  final data = json['data'];
  if (data == null) return;

  ref.read(pumpStatusProvider.notifier).updateFromWs(data);
  logger.t("[WS] Pump status updated: $data");
}
