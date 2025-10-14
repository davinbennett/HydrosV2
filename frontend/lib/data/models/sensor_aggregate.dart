import 'package:frontend/domain/entities/sensor_aggregate.dart';

class SensorAggregateModel extends SensorAggregateEntity {
  const SensorAggregateModel({
    super.id,
    super.deviceId,
    super.avgTemperature,
    super.avgHumidity,
    super.avgSoilMoisture,
    super.intervalStart,
    super.intervalEnd,
    super.createdAt,
    super.updatedAt,
  });

  factory SensorAggregateModel.fromJson(Map<String, dynamic> json) {
    return SensorAggregateModel(
      id: json['id'] as int?,
      deviceId: json['device_id'] as int,
      avgTemperature: (json['avg_temperature'] as num).toDouble(),
      avgHumidity: (json['avg_humidity'] as num).toDouble(),
      avgSoilMoisture: (json['avg_soil_moisture'] as num).toDouble(),
      intervalStart:
          json['interval_start'] != null
              ? DateTime.parse(json['interval_start'])
              : null,
      intervalEnd:
          json['interval_end'] != null
              ? DateTime.parse(json['interval_end'])
              : null,
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
      'device_id': deviceId,
      'avg_temperature': avgTemperature,
      'avg_humidity': avgHumidity,
      'avg_soil_moisture': avgSoilMoisture,
      'interval_start': intervalStart?.toIso8601String(),
      'interval_end': intervalEnd?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SensorAggregateEntity toEntity() => SensorAggregateEntity(
    id: id,
    deviceId: deviceId,
    avgTemperature: avgTemperature,
    avgHumidity: avgHumidity,
    avgSoilMoisture: avgSoilMoisture,
    intervalStart: intervalStart,
    intervalEnd: intervalEnd,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
