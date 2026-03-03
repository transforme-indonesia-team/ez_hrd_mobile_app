import 'package:hrd_app/data/services/base_api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _api = BaseApiService();

  Future<Map<String, dynamic>> getNotification({
    required String notifType,
  }) async {
    return _api.get(
      '/notification/get-by-employee',
      queryParameters: {'notif_type': notifType},
    );
  }

  Future<Map<String, dynamic>> getCountNotification() async {
    return _api.get('/notification/get-count');
  }

  Future<Map<String, dynamic>> markAsRead({
    List<String>? notificationIds,
  }) async {
    return _api.post('/notification/mark-as-read', {
      'notification_id': notificationIds,
    });
  }
}
