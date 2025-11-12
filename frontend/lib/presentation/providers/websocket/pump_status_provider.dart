import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';

class PumpStatusState {
  final bool? pumpStatus; // true = ON, false = OFF
  final String? controlBy; // manual/auto
  final String? time;

  const PumpStatusState({this.pumpStatus, this.controlBy, this.time});

  factory PumpStatusState.fromJson(Map<String, dynamic> json) {
    return PumpStatusState(
      pumpStatus: json['pump_status'] == true || json['pump_status'] == 1,
      controlBy: json['control_by']?.toString(),
      time: json['time']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'pump_status': pumpStatus,
    'control_by': controlBy,
    'time': time,
  };
}

class PumpStatusNotifier extends StateNotifier<PumpStatusState> {
  PumpStatusNotifier() : super(const PumpStatusState());

  Future<void> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('last_pump_status');
    if (jsonString != null) {
      try {
        final data = jsonDecode(jsonString);
        state = PumpStatusState.fromJson(Map<String, dynamic>.from(data));
      } catch (_) {}
    }
  }

  void updateFromWs(Map<String, dynamic> data) async {
    state = PumpStatusState.fromJson(data);

    // Simpan ke local
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_device_status', jsonEncode(data));
    } catch (e) {
      logger.e("[DeviceStatus] Gagal simpan cache: $e");
    }

    logger.t("[DeviceStatus] ✅ Updated from WebSocket: $data");
  }
}

final pumpStatusProvider =
    StateNotifierProvider<PumpStatusNotifier, PumpStatusState>((ref) {
      return PumpStatusNotifier();
    });
