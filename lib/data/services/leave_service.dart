import 'package:hrd_app/data/services/base_api_service.dart';

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
}
