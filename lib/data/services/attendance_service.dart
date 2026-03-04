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

  Future<Map<String, dynamic>> getAbsentEmployee({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return _api.get(
      '/attendance/absent-by-employee',
      queryParameters: {
        'start_date': startDate != null ? dateFormat.format(startDate) : null,
        'end_date': endDate != null ? dateFormat.format(endDate) : null,
      },
    );
  }

  Future<Map<String, dynamic>> absent({
    required double latitude,
    required double longitude,
    required File photo,
    required String employeeCode,
  }) async {
    final fileExists = await photo.exists();

    if (!fileExists) {
      throw Exception('File foto tidak ditemukan');
    }

    final fileName =
        'attendance_${DateTime.now().millisecondsSinceEpoch}${path.extension(photo.path)}';
    final absentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final location = '$latitude, $longitude';

    final formData = FormData.fromMap({
      'attendance_location': location,
      'attendance_photo': await MultipartFile.fromFile(
        photo.path,
        filename: fileName,
        contentType: DioMediaType('image', 'jpeg'),
      ),
      'employee_code': employeeCode,
      'absent': absentTime,
      // 'absent': '2026-03-04 10:15:00',
    });

    return _api.postFormData('/attendance/absent', formData);
  }

  /// Sama seperti [absent] tapi dengan waktu absen yang sudah ditentukan.
  /// Digunakan untuk sync absensi offline yang sudah tersimpan lokal.
  Future<Map<String, dynamic>> absentWithTime({
    required double latitude,
    required double longitude,
    required File photo,
    required String absentTime,
  }) async {
    final fileExists = await photo.exists();

    if (!fileExists) {
      throw Exception('File foto tidak ditemukan');
    }

    final fileName =
        'attendance_${DateTime.now().millisecondsSinceEpoch}${path.extension(photo.path)}';
    final location = '$latitude, $longitude';

    final formData = FormData.fromMap({
      'attendance_location': location,
      'attendance_photo': await MultipartFile.fromFile(
        photo.path,
        filename: fileName,
        contentType: DioMediaType('image', 'jpeg'),
      ),
      'absent': absentTime,
    });

    return _api.postFormData('/attendance/absent', formData);
  }

  Future<Map<String, dynamic>> getSchedule({
    String? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return _api.get(
      '/attendance/schedule-by-employee',
      queryParameters: {
        'employee_id': employeeId,
        'start_date': startDate != null ? dateFormat.format(startDate) : null,
        'end_date': endDate != null ? dateFormat.format(endDate) : null,
      },
    );
  }

  Future<Map<String, dynamic>> getAttendanceHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    return _api.get(
      '/attendance/absent-by-employee',
      queryParameters: {
        'start_date': startDate != null
            ? dateFormat.format(startDate)
            : dateFormat.format(now.subtract(const Duration(days: 30))),
        'end_date': endDate != null
            ? dateFormat.format(endDate)
            : dateFormat.format(now),
      },
    );
  }

  Future<Map<String, dynamic>> getScheduleCorrectionByEmployee({
    DateTime? startDate,
    DateTime? endDate,
    String? employeeId,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    return _api.post('/attendance/get-schedule-by-employee', {
      'employee_id': employeeId,
      'type': 'CORRECTION',
      'start_date': startDate != null
          ? dateFormat.format(startDate)
          : dateFormat.format(now.subtract(const Duration(days: 30))),
      'end_date': endDate != null
          ? dateFormat.format(endDate)
          : dateFormat.format(now),
    });
  }

  Future<Map<String, dynamic>> getLocation({
    String? employeeId,
    DateTime? date,
    String? type,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    return _api.get(
      '/attendance/get-location',
      queryParameters: {
        'employee_id': employeeId,
        'date': date != null ? dateFormat.format(date) : dateFormat.format(now),
        'type': type,
      },
    );
  }

  Future<Map<String, dynamic>> getScheduleByEmployee({
    List<Map<String, dynamic>>? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    return _api.post('/attendance/get-schedule-by-employee', {
      'employee_id': employeeId,
      'start_date': startDate != null
          ? dateFormat.format(startDate)
          : dateFormat.format(now.subtract(const Duration(days: 30))),
      'end_date': endDate != null
          ? dateFormat.format(endDate)
          : dateFormat.format(now),
    });
  }
}
