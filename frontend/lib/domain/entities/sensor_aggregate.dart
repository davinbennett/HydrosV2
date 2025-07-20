class SensorAggregateEntity {
  final int? id;
  final int? deviceId;
  final double? avgTemperature;
  final double? avgHumidity;
  final double? avgSoilMoisture;
  final DateTime? intervalStart;
  final DateTime? intervalEnd;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SensorAggregateEntity({
    this.id,
    this.deviceId,
    this.avgTemperature,
    this.avgHumidity,
    this.avgSoilMoisture,
    this.intervalStart,
    this.intervalEnd,
    this.createdAt,
    this.updatedAt,
  });
}
