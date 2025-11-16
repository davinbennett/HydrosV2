import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/alarm_state.dart';
import 'injection.dart';

final alarmProvider = StateNotifierProvider<AlarmNotifier, AlarmState>(
  (ref) => AlarmNotifier(ref),
);

class AlarmNotifier extends StateNotifier<AlarmState> {
  final Ref ref;

  AlarmNotifier(this.ref)
    : super(
        const AlarmState(listAlarm: [], nextAlarmStr: ''),
      );

  void updateEnabledFromUI(String alarmId, bool isEnabled) {
    final updated =
        state.listAlarm.map((a) {
          if (a['id'].toString() == alarmId) {
            return {...a, 'is_enabled': isEnabled};
          }
          return a;
        }).toList();

    state = state.copyWith(listAlarm: updated);
  }


  Future<void> loadAlarm(String deviceId) async {
    final service = ref.read(serviceControllerProvider);

    final result = await service.fetchAlarmController(deviceId);

    final list = List<Map<String, dynamic>>.from(result['list_alarm'] ?? []);
    final nextAlarm = result['next_alarm']?.toString() ?? '';

    state = state.copyWith(listAlarm: list, nextAlarmStr: nextAlarm);
  }

  void addAlarm(Map<String, dynamic> alarm) {
    final updated = [...state.listAlarm, alarm];
    state = state.copyWith(listAlarm: updated);
  }

  void removeAlarm(int id) {
    final updated = state.listAlarm.where((item) => item["id"] != id).toList();
    state = state.copyWith(listAlarm: updated);
  }

  void updateAlarm(Map<String, dynamic> alarm) {
    final updated =
        state.listAlarm.map((item) {
          if (item["id"] == alarm["id"]) return alarm;
          return item;
        }).toList();

    state = state.copyWith(listAlarm: updated);
  }

  void updateEnabledFromWS(dynamic alarmIdRaw, bool isEnabled) {
    final id = alarmIdRaw.toString();

    final updated =
        state.listAlarm.map((item) {
          if (item['id'].toString() == id) {
            return {...item, 'is_enabled': isEnabled};
          }
          return item;
        }).toList();

    state = state.copyWith(listAlarm: updated);
  }

}
