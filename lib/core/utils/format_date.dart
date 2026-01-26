import 'package:intl/intl.dart';

class FormatDate {
  static String todayWithDayName(DateTime date) {
    final dayName = DateFormat('EEE', 'id_ID').format(date);
    final formatted = DateFormat('dd MMM yyyy', 'id_ID').format(date);
    return '($dayName, $formatted)';
  }

  static String fullDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  static String shortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String time(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String dayWithFullDate(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(date);
  }

  static String shortDateWithYear(DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  static String dateRange(DateTime start, DateTime end) {
    return '${shortDateWithYear(start)} - ${shortDateWithYear(end)}';
  }

  static String apiFormat(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
