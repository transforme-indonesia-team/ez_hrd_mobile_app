import 'package:hrd_app/data/services/base_api_service.dart';

class SlipGajiService {
  static final SlipGajiService _instance = SlipGajiService._internal();
  factory SlipGajiService() => _instance;
  SlipGajiService._internal();
  final _api = BaseApiService();

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
