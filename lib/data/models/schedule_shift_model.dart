import 'package:hrd_app/data/models/shift_data_model.dart';

class ScheduleShiftModel {
  final String? date;
  final List<ShiftDataModel> shiftData;

  const ScheduleShiftModel({this.date, this.shiftData = const []});

  factory ScheduleShiftModel.fromJson(Map<String, dynamic> json) {
    return ScheduleShiftModel(
      date: json['date'] as String?,
      shiftData:
          (json['shift_data'] as List<dynamic>?)
              ?.map((e) => ShiftDataModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  ShiftDataModel? get firstShift =>
      shiftData.isNotEmpty ? shiftData.first : null;

  String get displayShiftName =>
      firstShift?.displayShiftName ?? 'Tidak ada shift';
  String get displayTime => firstShift?.displayTime ?? '-';
}
