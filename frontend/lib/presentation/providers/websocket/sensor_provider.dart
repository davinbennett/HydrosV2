import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State untuk data sensor
class SensorState {
  final double? temperature;
  final double? humidity;
  final double? soil;

  const SensorState({this.temperature, this.humidity, this.soil});

  SensorState copyWith({double? temperature, double? humidity, double? soil}) {
    return SensorState(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      soil: soil ?? this.soil,
    );
  }

  factory SensorState.fromJson(Map<String, dynamic> json) {
    return SensorState(
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      soil: (json['soil'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'humidity': humidity,
    'soil': soil,
  };
}

class SensorNotifier extends StateNotifier<SensorState> {
  SensorNotifier() : super(const SensorState());

  /// Load cache dari SharedPreferences
  Future<void> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('last_sensor_data');
    if (jsonString != null) {
      try {
        final map = jsonDecode(jsonString);
        final data = map['data'] ?? map;
        state = SensorState.fromJson(Map<String, dynamic>.from(data));
      } catch (_) {}
    }
  }

  /// Update dari WebSocket
  Future<void> updateFromWs(Map<String, dynamic> data) async {
    state = SensorState.fromJson(data);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_sensor_data', jsonEncode(data));
  }
}

final sensorProvider = StateNotifierProvider<SensorNotifier, SensorState>((
  ref,
) {
  return SensorNotifier();
});
