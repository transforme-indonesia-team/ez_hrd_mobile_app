import 'package:intl/intl.dart';

class FormatDate {
  // Format: (Rab, 07 Jan 2026)
  static String todayWithDayName(DateTime date) {
    final dayName = DateFormat('EEE', 'id_ID').format(date);
    final formatted = DateFormat('dd MMM yyyy', 'id_ID').format(date);
    return '($dayName, $formatted)';
  }

  // Format: 07 Januari 2026
  static String fullDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  // Format: 07/01/2026
  static String shortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format: 14:30
  static String time(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
