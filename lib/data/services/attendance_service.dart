import 'dart:io';
import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
import 'package:hrd_app/data/services/base_api_service.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final _api = BaseApiService();

  Future<Map<String, dynamic>> absent({
    required double latitude,
    required double longitude,
    required File photo,
  }) async {
    final fileExists = await photo.exists();
    // final fileSize = fileExists ? await photo.length() : 0;
    // debugPrint(
    //   'DEBUG-Attendance: File exists: $fileExists, size: $fileSize bytes',
    // );
    // debugPrint('DEBUG-Attendance: File path: ${photo.path}');

    if (!fileExists) {
      throw Exception('File foto tidak ditemukan');
    }

    final fileName =
        'attendance_${DateTime.now().millisecondsSinceEpoch}${path.extension(photo.path)}';
    final absentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final location = '$latitude, $longitude';

    // debugPrint('DEBUG-Attendance: attendance_location = $location');
    // debugPrint('DEBUG-Attendance: absent = $absentTime');
    // debugPrint('DEBUG-Attendance: filename = $fileName');

    final formData = FormData.fromMap({
      'attendance_location': location,
      'attendance_photo': await MultipartFile.fromFile(
        photo.path,
        filename: fileName,
        contentType: DioMediaType('image', 'jpeg'),
      ),
      'absent': absentTime,
    });

    // Debug: Print FormData fields
    // debugPrint('DEBUG-Attendance: FormData fields:');
    // for (final field in formData.fields) {
    //   debugPrint('  ${field.key}: ${field.value}');
    // }
    // debugPrint('DEBUG-Attendance: FormData files:');
    // for (final file in formData.files) {
    //   debugPrint(
    //     '  ${file.key}: ${file.value.filename} (${file.value.length} bytes)',
    //   );
    // }

    return _api.postFormData('/attendance/absent', formData);
  }
}
