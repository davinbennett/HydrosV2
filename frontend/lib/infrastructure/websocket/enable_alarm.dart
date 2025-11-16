import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logger.dart';
import '../../presentation/providers/alarm_provider.dart';

void handleUpdateEnabled(Ref ref, Map<String, dynamic> json) {
  try {
    final data = json['data'];
    final bool? isEnabled = data?['is_enabled'];
    final alarmId = data['alarm_id'];

    if (isEnabled == null) return;

    // Update provider alarm
    ref.read(alarmProvider.notifier).updateEnabledFromWS(alarmId, isEnabled);

    logger.i("[WS] Alarm enabled updated: $isEnabled");
  } catch (e) {
    logger.e("[WS] handleUpdateEnabled error: $e");
  }
}
