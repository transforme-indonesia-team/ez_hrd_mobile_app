import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hrd_app/data/services/attendance_sync_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;
  bool _hasCheckedInitial = false;

  bool get isOnline => _isOnline;

  /// Inisialisasi: cek status awal dan mulai listen perubahan
  Future<void> initialize() async {
    // Cek status awal
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = _isConnected(result);
      _hasCheckedInitial = true;
      debugPrint('ConnectivityProvider: Initial status: $_isOnline');
    } catch (e) {
      debugPrint('ConnectivityProvider: Failed to check initial status: $e');
      _isOnline = true; // Assume online if can't check
      _hasCheckedInitial = true;
    }

    // Listen perubahan connectivity
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasOffline = !_isOnline;
    _isOnline = _isConnected(results);

    debugPrint(
      'ConnectivityProvider: Connectivity changed → '
      '${_isOnline ? "ONLINE" : "OFFLINE"}',
    );

    notifyListeners();

    // Jika baru saja kembali online → trigger sync otomatis
    if (wasOffline && _isOnline && _hasCheckedInitial) {
      debugPrint('ConnectivityProvider: Back online! Triggering auto-sync...');
      _triggerAutoSync();
    }
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet,
    );
  }

  Future<void> _triggerAutoSync() async {
    try {
      await AttendanceSyncService().syncPendingAttendance();
    } catch (e) {
      debugPrint('ConnectivityProvider: Auto-sync failed: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
