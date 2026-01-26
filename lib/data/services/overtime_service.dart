import 'package:hrd_app/data/services/base_api_service.dart';

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
        if (limit != null) 'limit': limit,
        if (search != null) 'search': search,
      },
    );
  }
}
