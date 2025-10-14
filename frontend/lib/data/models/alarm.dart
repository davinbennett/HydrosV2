import 'package:frontend/domain/entities/alarm.dart';

class AlarmModel extends AlarmEntity {
  const AlarmModel({
    super.id,
    super.deviceId,
    super.isExecuted,
    super.scheduleTime,
    super.createdAt,
    super.updatedAt,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      deviceId: json['device_id'],
      isExecuted: json['is_executed'] as bool,
      scheduleTime: DateTime.parse(json['schedule_time']),
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
      'is_executed': isExecuted,
      'schedule_time': scheduleTime?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  AlarmEntity toEntity() => AlarmEntity(
    id: id,
    deviceId: deviceId,
    isExecuted: isExecuted,
    scheduleTime: scheduleTime,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
