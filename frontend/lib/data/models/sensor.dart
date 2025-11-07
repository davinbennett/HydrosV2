import 'package:frontend/domain/entities/sensor.dart';

class SensorModel extends SensorEntity {
  const SensorModel({
    super.temperature,
    super.humidity,
    super.soil,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return SensorModel(
      temperature: parseDouble(json['temperature'] ?? json['temp']),
      humidity: parseDouble(json['humidity']),
      soil: parseDouble(json['soil'] ?? json['soil_moisture']),
    );
  }

  Map<String, dynamic> toJson() {
    return{
      'temperature': temperature,
      'humidity': humidity,
      'soil': soil
    };
  }

  SensorEntity toEntity() => SensorEntity(
    temperature: temperature,
    humidity: humidity,
    soil: soil
  );
  
}
