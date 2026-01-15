import 'package:hrd_app/data/services/base_api_service.dart';

class EmployeeService {
  static final EmployeeService _instance = EmployeeService._internal();
  factory EmployeeService() => _instance;
  EmployeeService._internal();

  final _api = BaseApiService();

  Future<Map<String, dynamic>> getRelation({String? relation}) async {
    return _api.get(
      '/employee/get-relation',
      queryParameters: {'relation': relation},
    );
  }
}
