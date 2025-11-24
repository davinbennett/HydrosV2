import 'package:intl/intl.dart';

String formatLastPumped(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty || dateStr == '-') return '-';

  final parsed = DateTime.tryParse(dateStr);
  if (parsed == null) return '-';

  final dt = parsed.toLocal();

  final month = DateFormat("MMM").format(dt); // Jul
  final day = dt.day; // 5
  final year = DateFormat("yy").format(dt); // 25
  final time = DateFormat("HH:mm:ss").format(dt); // 14:00:00

  return "$month $day’ $year - $time";
}
