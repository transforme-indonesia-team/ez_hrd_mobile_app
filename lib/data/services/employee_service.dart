import 'package:hrd_app/data/services/base_api_service.dart';

class EmployeeService {
  static final EmployeeService _instance = EmployeeService._internal();
  factory EmployeeService() => _instance;
  EmployeeService._internal();

  final _api = BaseApiService();

  Future<Map<String, dynamic>> getRelation({
    String? relation,
    String? employeeCode,
  }) async {
    return _api.get(
      '/employee/get-relation',
      queryParameters: {'relation': relation, 'employee_code': employeeCode},
    );
  }

  Future<Map<String, dynamic>> getDetail({String? employeeCode}) async {
    return _api.get(
      '/employee/get-detail',
      queryParameters: {'employee_code': employeeCode},
    );
  }

  Future<Map<String, dynamic>> getMember({
    String? employeeId,
    String? search,
    int? page,
  }) async {
    return _api.get(
      '/employee/get-member',
      queryParameters: {
        if (employeeId != null) 'employee_id': employeeId,
        if (search != null) 'search': search,
        if (page != null) 'page': page,
      },
    );
  }
}
