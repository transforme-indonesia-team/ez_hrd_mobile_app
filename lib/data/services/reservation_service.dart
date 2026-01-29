import 'package:hrd_app/data/services/base_api_service.dart';

class ReservationService {
  static final ReservationService _instance = ReservationService._internal();
  factory ReservationService() => _instance;
  ReservationService._internal();
  final _api = BaseApiService();
  Future<Map<String, dynamic>> getReservationNumber({
    required String reservationType,
    required String companyId,
  }) async {
    return _api.post(
      '/get-reservation-number',
      {'reservation_type': reservationType},
      extraHeaders: {'company-id': companyId},
    );
  }
}
