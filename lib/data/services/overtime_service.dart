import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hrd_app/data/services/base_api_service.dart';
import 'package:path/path.dart' as path;

class OvertimeService {
  static final OvertimeService _instance = OvertimeService._internal();
  factory OvertimeService() => _instance;
  OvertimeService._internal();

  final _api = BaseApiService();

  Future<Map<String, dynamic>> getOvertimeEmployee({
    int? page,
    int? limit,
    String? search,
  }) async {
    return _api.get(
      '/overtime',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'sizes': limit,
        if (search != null) 'search': search,
      },
    );
  }

  Future<Map<String, dynamic>> getDetailOvertime({
    required String overtimeId,
  }) async {
    return _api.get('/overtime/$overtimeId');
  }

  Future<Map<String, dynamic>> getReservationNumber({
    required String reservationType,
    required String companyId,
  }) async {
    return _api.post(
      '/get-reservation-number',
      {'reservation_type': reservationType},
      extraHeaders: {'company-id': companyId},
    );
  }

  Future<Map<String, dynamic>> createOvertime({
    required String overtimeRequestNo,
    required String dateOvertime,
    required String startOvertime,
    required String endOvertime,
    required String remarkOvertime,
    required String employeeId,
    File? fileAttachment,
  }) async {
    final Map<String, dynamic> formMap = {
      'overtime_request_no': overtimeRequestNo,
      'date_overtime': dateOvertime,
      'start_overtime': startOvertime,
      'end_overtime': endOvertime,
      'remark_overtime': remarkOvertime,
      'employee_id': employeeId,
    };

    if (fileAttachment != null) {
      final fileExists = await fileAttachment.exists();
      if (fileExists) {
        final fileName = path.basename(fileAttachment.path);
        final extension = path
            .extension(fileAttachment.path)
            .replaceAll('.', '');

        formMap['file_attachment_overtime'] = await MultipartFile.fromFile(
          fileAttachment.path,
          filename: fileName,
          contentType: DioMediaType('application', extension),
        );
      }
    }

    final formData = FormData.fromMap(formMap);
    return _api.postFormData('/overtime', formData);
  }

  Future<Map<String, dynamic>> updateOvertime({
    required String overtimeId,
    required String overtimeRequestNo,
    required String dateOvertime,
    required String startOvertime,
    required String endOvertime,
    required String remarkOvertime,
    required String employeeId,
    File? fileAttachment,
  }) async {
    final Map<String, dynamic> formMap = {
      'overtime_request_no': overtimeRequestNo,
      'date_overtime': dateOvertime,
      'start_overtime': startOvertime,
      'end_overtime': endOvertime,
      'remark_overtime': remarkOvertime,
      'employee_id': employeeId,
    };

    if (fileAttachment != null) {
      final fileExists = await fileAttachment.exists();
      if (fileExists) {
        final fileName = path.basename(fileAttachment.path);
        final extension = path
            .extension(fileAttachment.path)
            .replaceAll('.', '');

        formMap['file_attachment_overtime'] = await MultipartFile.fromFile(
          fileAttachment.path,
          filename: fileName,
          contentType: DioMediaType('application', extension),
        );
      }
    }

    final formData = FormData.fromMap(formMap);
    return _api.postFormData('/overtime/$overtimeId?method=_PUT', formData);
  }

  Future<Map<String, dynamic>> cancellationOVertime({
    required String overtimeId,
  }) async {
    return _api.post('/overtime/cancellation/$overtimeId', {});
  }
}
