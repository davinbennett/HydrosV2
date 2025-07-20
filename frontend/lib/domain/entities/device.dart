class DeviceEntity {
  final int? id;
  final double? minSoilSetting;
  final double? maxSoilSetting;
  final bool? isOn;
  final double? latitude;
  final double? longitude;
  final String? location;
  final int? progressPlan;
  final int? progressNow;
  final String? code;
  final String? plantName;
  final bool? isActiveSoil;
  final bool? isActivePump;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeviceEntity({
    this.id,
    this.minSoilSetting,
    this.maxSoilSetting,
    this.isOn,
    this.latitude,
    this.longitude,
    this.location,
    this.progressPlan,
    this.progressNow,
    this.code,
    this.plantName,
    this.isActiveSoil,
    this.isActivePump,
    this.createdAt,
    this.updatedAt,
  });
}
