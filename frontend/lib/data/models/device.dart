import 'package:frontend/domain/entities/device.dart';

class DeviceModel extends DeviceEntity {
  const DeviceModel({
    super.id,
    super.minSoilSetting,
    super.maxSoilSetting,
    super.isOn,
    super.latitude,
    super.longitude,
    super.location,
    super.progressPlan,
    super.progressNow,
    super.code,
    super.plantName,
    super.isActiveSoil,
    super.isActivePump,
    super.createdAt,
    super.updatedAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      minSoilSetting: (json['min_soil_setting'] as num).toDouble(),
      maxSoilSetting: (json['max_soil_setting'] as num).toDouble(),
      isOn: json['is_on'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      location: json['location'],
      progressPlan: json['progress_plan'],
      progressNow: json['progress_now'],
      code: json['code'],
      plantName: json['plant_name'],
      isActiveSoil: json['is_active_soil'],
      isActivePump: json['is_active_pump'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'min_soil_setting': minSoilSetting,
      'max_soil_setting': maxSoilSetting,
      'is_on': isOn,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'progress_plan': progressPlan,
      'progress_now': progressNow,
      'code': code,
      'plant_name': plantName,
      'is_active_soil': isActiveSoil,
      'is_active_pump': isActivePump,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DeviceEntity toEntity() => DeviceEntity(
    id: id,
    minSoilSetting: minSoilSetting,
    maxSoilSetting: maxSoilSetting,
    isOn: isOn,
    latitude: latitude,
    longitude: longitude,
    location: location,
    progressPlan: progressPlan,
    progressNow: progressNow,
    code: code,
    plantName: plantName,
    isActiveSoil: isActiveSoil,
    isActivePump: isActivePump,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
