import 'package:hrd_app/data/services/base_api_service.dart';

class OvertimeService {
  static final OvertimeService _instance = OvertimeService._internal();
  factory OvertimeService() => _instance;
  OvertimeService._internal();

  final _api = BaseApiService();

  Future<Map<String, dynamic>> getOvertimeEmployee({
    int? pages,
    int? sizes,
    String? search,
  }) async {
    return _api.get(
      '/overtime',
      queryParameters: {
        if (pages != null) 'pages': pages,
        if (sizes != null) 'sizes': sizes,
        if (search != null) 'search': search,
      },
    );
  }
}
