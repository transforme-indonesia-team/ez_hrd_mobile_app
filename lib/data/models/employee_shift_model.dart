class EmployeeShiftModel {
  final String? scheduleId;
  final String? shiftDailyCode;
  final String? startShiftTime;
  final String? endShiftTime;
  final String? dateSchedule;
  final String? checkIn;
  final String? checkOut;
  final String? attendancePhotoIn;
  final String? attendancePhotoOut;

  const EmployeeShiftModel({
    this.scheduleId,
    this.shiftDailyCode,
    this.startShiftTime,
    this.endShiftTime,
    this.dateSchedule,
    this.checkIn,
    this.checkOut,
    this.attendancePhotoIn,
    this.attendancePhotoOut,
  });

  factory EmployeeShiftModel.fromJson(Map<String, dynamic> json) {
    return EmployeeShiftModel(
      scheduleId: json['schedule_id'] as String?,
      shiftDailyCode: json['shift_daily_code'] as String?,
      startShiftTime: json['start_shift_time'] as String?,
      endShiftTime: json['end_shift_time'] as String?,
      dateSchedule: json['date_schedule'] as String?,
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
      attendancePhotoIn: json['attendance_photo_in'] as String?,
      attendancePhotoOut: json['attendance_photo_out'] as String?,
    );
  }

  String get displayShiftInfo {
    final start = startShiftTime ?? '--:--';
    final end = endShiftTime ?? '--:--';
    return 'Shift: Shift Office Hour [$start - $end]';
  }

  String? get formattedCheckIn => _formatTime(checkIn);
  String? get formattedCheckOut => _formatTime(checkOut);

  String? get formattedPhotoIn => _formatPhoto(attendancePhotoIn);

  String? get formattedPhotoOut => _formatPhoto(attendancePhotoOut);

  String? _formatTime(String? time) {
    if (time == null || time.isEmpty || time == '-') return null;
    return time;
  }

  String? _formatPhoto(String? photo) {
    if (photo == null || photo.isEmpty || photo == '-') return null;
    return photo;
  }
}
