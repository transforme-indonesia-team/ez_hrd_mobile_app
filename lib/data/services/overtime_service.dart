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
    String? startDate,
    String? endDate,
  }) async {
    return _api.get(
      '/overtime',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'sizes': limit,
        if (search != null) 'search': search,
        if (startDate != null) 'filter[start_date]': startDate,
        if (endDate != null) 'filter[end_date]': endDate,
      },
    );
  }

  Future<Map<String, dynamic>> getDetailOvertime({
    required String overtimeId,
  }) async {
    return _api.get('/overtime/$overtimeId');
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

  Future<Map<String, dynamic>> getOvertimeEmployeeApproval({
    int? page,
    int? limit,
    String? search,
    String? startDate,
    String? endDate,
    String? approvalStatus,
  }) async {
    return _api.get(
      '/overtime-approval',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'sizes': limit,
        if (search != null) 'search': search,
        if (startDate != null) 'filter[start_date]': startDate,
        if (endDate != null) 'filter[end_date]': endDate,
        if (approvalStatus != null) 'approval_status': approvalStatus,
      },
    );
  }

  Future<Map<String, dynamic>> cancellationOVertime({
    required String overtimeId,
  }) async {
    return _api.post('/overtime/cancellation/$overtimeId', {});
  }

  Future<Map<String, dynamic>> approvalOvertime({
    required String overtimeId,
    required String status,
    String? remark,
  }) async {
    return _api.post('/overtime-approval/$overtimeId', {
      'status_approval': status,
      'remark_approval': remark,
    });
  }

  Future<Map<String, dynamic>> batchApprovalOvertime({
    required List<String> overtimeIds,
    required String status,
    String? remark,
  }) async {
    return _api.post('/overtime-approval/batch-approval', {
      'status_approval': status,
      'remark_approval': remark ?? '',
      'overtime_employee_id': overtimeIds,
    });
  }
}
