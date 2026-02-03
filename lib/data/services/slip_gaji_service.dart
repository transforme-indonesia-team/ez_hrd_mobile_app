import 'package:hrd_app/data/services/base_api_service.dart';

class SlipGajiService {
  static final SlipGajiService _instance = SlipGajiService._internal();
  factory SlipGajiService() => _instance;
  SlipGajiService._internal();
  final _api = BaseApiService();

  Future<Map<String, dynamic>> payrollEmployeeDetail({
    required String companyId,
    required String employeeId,
    String? employeeName,
    required String periodMonth,
    required String periodYear,
  }) async {
    return _api.post(
      '/payroll/payslip-employee-detail',
      {
        'employee_id': employeeId,
        'employee_name': employeeName,
        'period_month': periodMonth,
        'period_year': periodYear,
      },
      extraHeaders: {'company-id': companyId},
    );
  }

  Future<Map<String, dynamic>> paySLipEmployee() async {
    return _api.get("/payroll/payslip-employee");
  }

  Future<Map<String, dynamic>> checkPasswordPayroll({
    required String password,
    required String passwordPayroll,
  }) async {
    return _api.post('/payroll/check-password-payroll', {
      'password': password,
      'password_payroll': passwordPayroll,
    });
  }

  Future<Map<String, dynamic>> createSlipGajiSandi({
    required String password,
    required String passwordPayroll,
    required String confirmPasswordPayroll,
  }) async {
    return _api.post('/payroll/set-password-payroll', {
      'password': password,
      'password_payroll': passwordPayroll,
      'confirm_password_payroll': confirmPasswordPayroll,
    });
  }
}
