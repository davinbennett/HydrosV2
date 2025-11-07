
class SensorEntity {
  final double? temperature;
  final double? humidity;
  final double? soil;

  const SensorEntity({
    this.temperature,
    this.humidity,
    this.soil,
  });

  SensorEntity copyWith({double? temperature, double? humidity, double? soil}) {
    return SensorEntity(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      soil: soil ?? this.soil
    );
  }
}
