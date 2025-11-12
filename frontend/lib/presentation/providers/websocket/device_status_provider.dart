import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceStatusState {
  final String? status; // online/offline

  const DeviceStatusState({this.status});

  factory DeviceStatusState.fromJson(Map<String, dynamic> json) {
    return DeviceStatusState(status: json['status']?.toString());
  }

  Map<String, dynamic> toJson() => {'status': status};
}

class DeviceStatusNotifier extends StateNotifier<DeviceStatusState> {
  DeviceStatusNotifier() : super(const DeviceStatusState());

  Future<void> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('last_device_status');
    if (jsonString != null) {
      try {
        final data = jsonDecode(jsonString);
        state = DeviceStatusState.fromJson(Map<String, dynamic>.from(data));
      } catch (_) {}
    }
  }

  void updateFromWs(Map<String, dynamic> data) async {
    state = DeviceStatusState.fromJson(data);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_device_status', jsonEncode(data));
  }
}

final deviceStatusProvider =
    StateNotifierProvider<DeviceStatusNotifier, DeviceStatusState>((ref) {
      return DeviceStatusNotifier();
    });
