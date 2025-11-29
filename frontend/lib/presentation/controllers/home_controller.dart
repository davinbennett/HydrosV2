import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/domain/usecase/pumplog.dart';
import 'package:intl/intl.dart';
import '../../domain/usecase/ai.dart';
import '../../domain/usecase/device/device.dart';

class HomeController extends StateNotifier<Map<dynamic, dynamic>> {
  final Ref ref;
  final DeviceUsecase deviceUsecase;
  final PumplogUsecase pumplogUsecase;
  final AIUsecase aiUsecase;

  HomeController(this.deviceUsecase, this.ref, this.pumplogUsecase, this.aiUsecase) : super({});

  Future<String> addPlantController(
    String? deviceId,
    String? plantName,
    String? progressPlan,
    String? longitude,
    String? latitude,
    String? location,
  ) async {
    final data = await deviceUsecase.addPlantUsecase(
      deviceId,
      plantName,
      progressPlan,
      longitude,
      latitude,
      location,
    );
    return data;
  }
  
  Future<String> editPlantController(
    String? deviceId,
    String? plantName,
    String? progressPlan,
    String? longitude,
    String? latitude,
    String? location,
  ) async {
    final data = await deviceUsecase.editPlantUsecase(
      deviceId,
      plantName,
      progressPlan,
      longitude,
      latitude,
      location,
    );
    return data;
  }

  Future<Map<String, dynamic>> getPlantAssistantController(
    String deviceId,
  ) async {
    try {
      final location = await deviceUsecase.getLocationUsecase(deviceId);
      final weather = await deviceUsecase.getWeatherUsecase(deviceId);
      final plantInfo = await deviceUsecase.getPlantInfoUsecase(deviceId);
      final pumpUsage = await pumplogUsecase.getPumpUsageUsecase(deviceId);
      final lastWatered = await pumplogUsecase.getLastWateredUsecase(deviceId);

      // Format last_watered → HH:mm:ss
      String? lastWateredFormatted;
      try {
        final rawDate = lastWatered['last_watered'];
        if (rawDate != null) {
          final dt = DateTime.parse(rawDate).toLocal();
          lastWateredFormatted = DateFormat('HH:mm:ss').format(dt);
        }
      } catch (_) {
        lastWateredFormatted = null;
      }

      return {
        'location': location['location'] ?? '',
        'long': location['long'] ?? '',
        'lat': location['lat'] ?? '',
        'weather': weather['weather-status'] ?? '',
        'plant_name': plantInfo['plant_name'] ?? '',
        'progress_now': plantInfo['progress_now'] ?? 0,
        'progress_plan': plantInfo['progress_plan'] ?? 0,
        'pump_usage': pumpUsage['pump_usage'] ?? 0,
        'last_watered': lastWateredFormatted,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAiReportController(
    String? plantName,
    int? progressPlan,
    int? progressNow,
    String? longitude,
    String? latitude,
    double? temperature,
    double? soil,
    double? humidity,
    int? pumpUsage,
    String? lastWatered,
    String? time,
  ) async {
    final data = await aiUsecase.postAiReportUsecase(
      plantName,
      progressPlan,
      progressNow,
      longitude,
      latitude,
      temperature,
      soil,
      humidity,
      pumpUsage,
      lastWatered,
      time,
    );
    return data;
  }
}
