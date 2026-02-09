import 'package:hrd_app/core/utils/format_date.dart';

class AttendanceEmployeeModel {
  final String? scheduleId;
  final String? profile;
  final String? employeeId;
  final String? employeeCode;
  final String? employeeName;
  final String? positionName;
  final String? worksiteName;
  final String? dateSchedule;
  final String? shiftDailyCode;
  final String? startShiftTime;
  final String? endShiftTime;
  final String? checkIn;
  final String? checkOut;
  final String? attendancePhotoIn;
  final String? attendancePhotoOut;
  final int? overtimeMinutes;
  final String? remarkSchedule;

  AttendanceEmployeeModel({
    this.scheduleId,
    this.profile,
    this.employeeId,
    this.employeeCode,
    this.employeeName,
    this.positionName,
    this.worksiteName,
    this.dateSchedule,
    this.shiftDailyCode,
    this.startShiftTime,
    this.endShiftTime,
    this.checkIn,
    this.checkOut,
    this.attendancePhotoIn,
    this.attendancePhotoOut,
    this.overtimeMinutes,
    this.remarkSchedule,
  });

  factory AttendanceEmployeeModel.fromJson(Map<String, dynamic> json) {
    return AttendanceEmployeeModel(
      scheduleId: json['schedule_id'] as String?,
      profile: json['profile'] as String?,
      employeeId: json['employee_id'] as String?,
      employeeCode: json['employee_code'] as String?,
      employeeName: json['employee_name'] as String?,
      positionName: json['position_name'] as String?,
      worksiteName: json['worksite_name'] as String?,
      dateSchedule: json['date_schedule'] as String?,
      shiftDailyCode: json['shift_daily_code'] as String?,
      startShiftTime: json['start_shift_time'] as String?,
      endShiftTime: json['end_shift_time'] as String?,
      checkIn: _parseTimeValue(json['check_in']),
      checkOut: _parseTimeValue(json['check_out']),
      attendancePhotoIn: _parsePhotoValue(json['attendance_photo_in']),
      attendancePhotoOut: _parsePhotoValue(json['attendance_photo_out']),
      overtimeMinutes: json['overtime_minutes'] as int? ?? 0,
      remarkSchedule: json['remark_schedule'] as String?,
    );
  }

  static String? _parseTimeValue(dynamic value) {
    if (value == null || value == '-' || value == '') return null;
    return value.toString();
  }

  static String? _parsePhotoValue(dynamic value) {
    if (value == null || value == '-' || value == '') return null;
    return value.toString();
  }

  // Display helpers
  String get displayEmployeeName => employeeName ?? '-';

  String get displayDate {
    if (dateSchedule == null || dateSchedule!.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateSchedule!);
      return FormatDate.dayWithFullDate(date);
    } catch (e) {
      return dateSchedule ?? '-';
    }
  }

  String get displayShift {
    // Format shift code to readable name, e.g. "P10_10000_1800" -> "10:00 - 18:00"
    if (startShiftTime != null && endShiftTime != null) {
      return '$startShiftTime - $endShiftTime';
    }
    if (shiftDailyCode != null && shiftDailyCode!.isNotEmpty) {
      return shiftDailyCode!;
    }
    return '-';
  }

  String get displayOvertime {
    if (overtimeMinutes == null || overtimeMinutes == 0) return '0 min';
    if (overtimeMinutes! >= 60) {
      final hours = overtimeMinutes! ~/ 60;
      final mins = overtimeMinutes! % 60;
      if (mins == 0) return '$hours jam';
      return '$hours jam $mins min';
    }
    return '$overtimeMinutes min';
  }

  String get displayCheckIn => checkIn ?? '--:--';
  String get displayCheckOut => checkOut ?? '--:--';

  bool get hasCheckIn => checkIn != null && checkIn!.isNotEmpty;
  bool get hasCheckOut => checkOut != null && checkOut!.isNotEmpty;

  bool get hasPhotoIn =>
      attendancePhotoIn != null && attendancePhotoIn!.isNotEmpty;
  bool get hasPhotoOut =>
      attendancePhotoOut != null && attendancePhotoOut!.isNotEmpty;

  bool get isAbsent => !hasCheckIn && !hasCheckOut;

  String get displayStatus {
    if (isAbsent) return 'ABS';
    if (!hasCheckOut) return 'IN';
    return 'OK';
  }
}
