class ShiftDataModel {
  final String? shiftName;
  final String? time;
  final String? shiftType;
  final int? productiveWorkTime;

  const ShiftDataModel({
    this.shiftName,
    this.time,
    this.shiftType,
    this.productiveWorkTime,
  });

  factory ShiftDataModel.fromJson(Map<String, dynamic> json) {
    return ShiftDataModel(
      shiftName: json['shift_name'] as String,
      time: json['time'] as String,
      shiftType: json['shift_type'] as String,
      productiveWorkTime: json['productive_work_time'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shift_name': shiftName,
      'time': time,
      'shift_type': shiftType,
      'productive_work_time': productiveWorkTime,
    };
  }

  String get displayShiftName => shiftName ?? '-';
  String get displayTime => time ?? '-';
  bool get isWorkDay => shiftType == 'WORK';
}
