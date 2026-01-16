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
      'absent': absentTime,
    });

    return _api.postFormData('/attendance/absent', formData);
  }
}
