import 'package:dio/dio.dart';
import 'package:hrd_app/data/services/base_api_service.dart';

class AttendanceCorrectionService {
  static final AttendanceCorrectionService _instance =
      AttendanceCorrectionService._internal();
  factory AttendanceCorrectionService() => _instance;
  AttendanceCorrectionService._internal();

  final _api = BaseApiService();

  Future<Map<String, dynamic>> getAttendanceCorrection({
    String? pages,
    String? sizes,
    bool? search,
    String? employeeId,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    return _api.get(
      '/attendance-correction',
      queryParameters: {
        'pages': pages,
        'sizes': sizes,
        'search': search,
        'employee_id': employeeId,
        'start_date': startDate,
        'end_date': endDate,
        'status': status,
      },
    );
  }

  Future<Map<String, dynamic>> getAttendanceCorrectionById(String id) async {
    return _api.get('/attendance-correction/$id');
  }

  Future<Map<String, dynamic>> storeAttendanceCorrection(
    Map<String, dynamic> data,
  ) async {
    final formData = FormData.fromMap(data);
    return _api.postFormData('/attendance-correction', formData);
  }

  Future<Map<String, dynamic>> getAttendanceCorrectionApproval({
    String? pages,
    String? sizes,
    bool? search,
    String? employeeId,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    return _api.get(
      '/attendance-correction-approval',
      queryParameters: {
        'pages': pages,
        'sizes': sizes,
        'search': search,
        'employee_id': employeeId,
        'start_date': startDate,
        'end_date': endDate,
        'status': status,
      },
    );
  }

  Future<Map<String, dynamic>> deleteAttendanceCorrection(String id) async {
    return _api.delete('/attendance-correction/$id');
  }

  Future<Map<String, dynamic>> approvalAttendanceCorrection({
    required String attendanceCorrectionId,
    required String status,
    String? remark,
  }) async {
    return _api.post(
      '/attendance-correction-approval/$attendanceCorrectionId',
      {'status_approval': status, 'remark_approval': remark},
    );
  }

  Future<Map<String, dynamic>> batchApprovalAttendanceCorrection({
    required List<String> attendanceCorrectionIds,
    required String status,
    String? remark,
  }) async {
    return _api.post('/attendance-correction-approval/batch-approval', {
      'status_approval': status,
      'remark_approval': remark ?? '',
      'attendance_correction_id': attendanceCorrectionIds,
    });
  }
}
