import 'package:frontend/domain/entities/pumplog.dart';

class PumpLogModel extends PumpLogEntity {
  const PumpLogModel({
    super.id,
    super.deviceId,
    super.soilBefore,
    super.soilAfter,
    super.triggeredBy,
    super.startTime,
    super.endTime,
    super.createdAt,
    super.updatedAt,
  });

  factory PumpLogModel.fromJson(Map<String, dynamic> json) {
    return PumpLogModel(
      id: json['id'] as int?,
      deviceId: json['device_id'] as int,
      soilBefore: (json['soil_before'] as num).toDouble(),
      soilAfter: (json['soil_after'] as num).toDouble(),
      triggeredBy: json['triggered_by'] as String?,
      startTime:
          json['start_time'] != null
              ? DateTime.parse(json['start_time'])
              : null,
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
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
      'soil_before': soilBefore,
      'soil_after': soilAfter,
      'triggered_by': triggeredBy,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
