import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hrd_app/data/services/base_api_service.dart';
import 'package:path/path.dart' as path;

class LeaveService {
  static final LeaveService _instance = LeaveService._internal();
  factory LeaveService() => _instance;
  LeaveService._internal();
  final _api = BaseApiService();

  Future<Map<String, dynamic>> getLeaveEmployee({
    int? page,
    int? limit,
    String? search,
  }) async {
    return _api.get(
      '/leave',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'sizes': limit,
        if (search != null) 'search': search,
      },
    );
  }

  Future<Map<String, dynamic>> createLeaveEmployee({
    required String leaveRequestNo,
    required String startLeave,
    required String endLeave,
    required String leaveTypeId,
    required String remarkLeave,
    required String employeeId,
    File? fileAttachment,
  }) async {
    final Map<String, dynamic> formMap = {
      'leave_request_no': leaveRequestNo,
      'start_leave': startLeave,
      'end_leave': endLeave,
      'leave_type_id': leaveTypeId,
      'remark_leave': remarkLeave,
      'employee_id': employeeId,
    };

    if (fileAttachment != null) {
      final fileExists = await fileAttachment.exists();
      if (fileExists) {
        final fileName = path.basename(fileAttachment.path);
        final extension = path
            .extension(fileAttachment.path)
            .replaceAll('.', '');

        formMap['file_attachment_leave'] = await MultipartFile.fromFile(
          fileAttachment.path,
          filename: fileName,
          contentType: DioMediaType('application', extension),
        );
      }
    }

    final formData = FormData.fromMap(formMap);
    return _api.postFormData('/leave', formData);
  }

  Future<Map<String, dynamic>> updateLeaveEmployee({
    required String leaveId,
    required String leaveRequestNo,
    required String startLeave,
    required String endLeave,
    required String remarkLeave,
    required String employeeId,
    File? fileAttachment,
  }) async {
    final Map<String, dynamic> formMap = {
      'leave_request_no': leaveRequestNo,
      'start_leave': startLeave,
      'end_leave': endLeave,
      'remark_leave': remarkLeave,
      'employee_id': employeeId,
    };

    if (fileAttachment != null) {
      final fileExists = await fileAttachment.exists();
      if (fileExists) {
        final fileName = path.basename(fileAttachment.path);
        final extension = path
            .extension(fileAttachment.path)
            .replaceAll('.', '');

        formMap['file_attachment_leave'] = await MultipartFile.fromFile(
          fileAttachment.path,
          filename: fileName,
          contentType: DioMediaType('application', extension),
        );
      }
    }

    final formData = FormData.fromMap(formMap);
    return _api.postFormData('/leave/$leaveId?method=_PUT', formData);
  }
}
