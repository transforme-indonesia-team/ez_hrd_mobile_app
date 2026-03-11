class ScheduleShiftEmployeeModel {
  final String? employeeId;
  final String? employeeName;
  final String? employeeCode;
  final String? profile;
  final List<ScheduleShiftDay> shifts;

  const ScheduleShiftEmployeeModel({
    this.employeeId,
    this.employeeName,
    this.employeeCode,
    this.profile,
    this.shifts = const [],
  });

  factory ScheduleShiftEmployeeModel.fromJson(Map<String, dynamic> json) {
    final shiftsRaw = json['shifts'] as List<dynamic>? ?? [];
    return ScheduleShiftEmployeeModel(
      employeeId: json['employee_id'] as String?,
      employeeName: json['employee_name'] as String?,
      employeeCode: json['employee_code'] as String?,
      profile: json['profile'] as String?,
      shifts: shiftsRaw
          .map((e) => ScheduleShiftDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Total menit kerja produktif dari semua shift
  int get totalProductiveMinutes {
    int total = 0;
    for (final day in shifts) {
      for (final shift in day.shiftData) {
        total += shift.productiveWorkTime ?? 0;
      }
    }
    return total;
  }

  /// Jumlah hari yang ada shift-nya
  int get totalDays => shifts.length;

  /// Format tampilan "X Jam, Y Hari"
  String get displayTotalHours {
    final hours = totalProductiveMinutes ~/ 60;
    return '$hours Jam, $totalDays Hari';
  }
}

class ScheduleShiftDay {
  final String? date;
  final List<ScheduleShiftData> shiftData;

  ScheduleShiftDay({this.date, List<ScheduleShiftData>? shiftData})
    : shiftData = shiftData ?? [];

  factory ScheduleShiftDay.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['shift_data'] as List<dynamic>? ?? [];
    return ScheduleShiftDay(
      date: json['date'] as String?,
      shiftData: dataRaw
          .map((e) => ScheduleShiftData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Total jam produktif untuk hari ini
  int get totalMinutes {
    int total = 0;
    for (final shift in shiftData) {
      total += shift.productiveWorkTime ?? 0;
    }
    return total;
  }

  String get displayHours {
    final hours = totalMinutes ~/ 60;
    return '$hours Jam';
  }
}

class ScheduleShiftData {
  final String? shiftDailyId;
  final String? shiftName;
  final String? time;
  final String? shiftType;
  final int? productiveWorkTime;

  const ScheduleShiftData({
    this.shiftDailyId,
    this.shiftName,
    this.time,
    this.shiftType,
    this.productiveWorkTime,
  });

  factory ScheduleShiftData.fromJson(Map<String, dynamic> json) {
    return ScheduleShiftData(
      shiftDailyId: json['shift_daily_id'] as String?,
      shiftName: json['shift_name'] as String?,
      time: json['time'] as String?,
      shiftType: json['shift_type'] as String?,
      productiveWorkTime: json['productive_work_time'] as int?,
    );
  }
}
