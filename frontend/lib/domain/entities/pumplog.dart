class PumpLogEntity {
  final int? id;
  final int? deviceId;
  final double? soilBefore;
  final double? soilAfter;
  final String? triggeredBy;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PumpLogEntity({
    this.id,
    this.deviceId,
    this.soilBefore,
    this.soilAfter,
    this.triggeredBy,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.updatedAt,
  });
}
