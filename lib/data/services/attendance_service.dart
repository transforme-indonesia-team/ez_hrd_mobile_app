import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hrd_app/data/services/base_api_service.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final _api = BaseApiService();

  Future<Map<String, dynamic>> checkIn({
    required double latitude,
    required double longitude,
    required File photo,
  }) async {
    final fileName =
        'attendance_${DateTime.now().millisecondsSinceEpoch}${path.extension(photo.path)}';

    final formData = FormData.fromMap({
      'attendance_location_in': '$latitude, $longitude',
      'attendance_photo_in': await MultipartFile.fromFile(
        photo.path,
        filename: fileName,
      ),
      'check_in': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    });

    return _api.postFormData('/attendance/check-in-employee', formData);
  }
}
