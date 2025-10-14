class AlarmEntity {
  final String? id;
  final String? deviceId;
  final bool? isExecuted;
  final DateTime? scheduleTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AlarmEntity({
    this.id,
    this.deviceId,
    this.isExecuted,
    this.scheduleTime,
    this.createdAt,
    this.updatedAt,
  });
}
