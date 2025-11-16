String toIso8601WithOffset(DateTime dt) {
  final local = dt.toLocal();

  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final second = local.second.toString().padLeft(2, '0');

  // Indonesia WIB offset
  const offset = "+07:00";

  return "$year-$month-${day}T$hour:$minute:$second$offset";
}
