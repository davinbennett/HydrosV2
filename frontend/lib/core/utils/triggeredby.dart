String mapTriggeredBy(dynamic value) {
  switch (value) {
    case 1:
      return "Device";
    case 2:
      return "Switch";
    case 3:
      return "Auto Soil Control";
    case 4:
      return "Alarm Schedule";
    default:
      return "Unknown";
  }
}
