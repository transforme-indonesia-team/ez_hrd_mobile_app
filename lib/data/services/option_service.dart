import 'package:hrd_app/data/services/base_api_service.dart';

class OptionService {
  static final OptionService _instance = OptionService._internal();
  factory OptionService() => _instance;
  OptionService._internal();

  final _api = BaseApiService();

  Future<Map<String, dynamic>> getShiftDaily() async {
    return _api.get('/option/shift-daily');
  }

  Future<Map<String, dynamic>> getAttendaceStatus() async {
    return _api.get('/option/attendance-status');
  }
}
