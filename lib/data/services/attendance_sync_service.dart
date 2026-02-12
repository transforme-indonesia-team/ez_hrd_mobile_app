import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrd_app/data/models/pending_attendance_model.dart';
import 'package:hrd_app/data/services/attendance_service.dart';

class AttendanceSyncService {
  static final AttendanceSyncService _instance =
      AttendanceSyncService._internal();
  factory AttendanceSyncService() => _instance;
  AttendanceSyncService._internal();

  static const String _pendingKey = 'pending_attendance_records';
  static const int _maxRetries = 3;

  bool _isSyncing = false;

  // Callback untuk notify UI saat ada perubahan pending count
  VoidCallback? onPendingCountChanged;

  // ============ Save Offline ============

  /// Simpan absensi ke lokal saat offline
  Future<void> saveOffline({
    required double latitude,
    required double longitude,
    required File photo,
  }) async {
    // Copy foto ke app directory agar tidak hilang
    final appDir = await getApplicationDocumentsDirectory();
    final offlineDir = Directory('${appDir.path}/offline_attendance');
    if (!await offlineDir.exists()) {
      await offlineDir.create(recursive: true);
    }

    final fileName =
        'attendance_${DateTime.now().millisecondsSinceEpoch}${path.extension(photo.path)}';
    final savedPhoto = await photo.copy('${offlineDir.path}/$fileName');

    final absentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final record = PendingAttendanceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      latitude: latitude,
      longitude: longitude,
      photoPath: savedPhoto.path,
      absentTime: absentTime,
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
    );

    final records = await _loadRecords();
    records.add(record);
    await _saveRecords(records);

    debugPrint(
      'AttendanceSyncService: Saved offline attendance. '
      'Total pending: ${records.length}',
    );

    onPendingCountChanged?.call();
  }

  // ============ Sync ============

  /// Kirim semua absensi pending ke server
  Future<void> syncPendingAttendance() async {
    if (_isSyncing) {
      debugPrint('AttendanceSyncService: Sync already in progress, skipping.');
      return;
    }

    // Reset records yang failed karena auth error agar dicoba ulang
    await _resetFailedRecords();

    final records = await _loadRecords();
    final pendingRecords = records
        .where((r) => r.status == 'pending' || r.status == 'failed')
        .toList();

    if (pendingRecords.isEmpty) {
      debugPrint('AttendanceSyncService: No pending records to sync.');
      return;
    }

    _isSyncing = true;
    debugPrint(
      'AttendanceSyncService: Starting sync of ${pendingRecords.length} records...',
    );

    for (final record in pendingRecords) {
      try {
        // Update status ke syncing
        await _updateRecordStatus(record.id, 'syncing');

        final photoFile = File(record.photoPath);
        if (!await photoFile.exists()) {
          debugPrint(
            'AttendanceSyncService: Photo not found for record ${record.id}, '
            'removing record.',
          );
          await _removeRecord(record.id);
          continue;
        }

        // Kirim ke API
        await AttendanceService().absentWithTime(
          latitude: record.latitude,
          longitude: record.longitude,
          photo: photoFile,
          absentTime: record.absentTime,
        );

        debugPrint(
          'AttendanceSyncService: ✅ Record ${record.id} synced successfully.',
        );

        // Hapus record dan foto setelah sukses
        await _removeRecord(record.id);
        await _deletePhotoFile(record.photoPath);
      } catch (e) {
        final errorMsg = e.toString();
        debugPrint(
          'AttendanceSyncService: ❌ Failed to sync record ${record.id}: $errorMsg',
        );

        // Jika 401 (Unauthorized) → token expired, stop sync.
        // Jangan hitung sebagai retry, tunggu user login ulang.
        if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
          debugPrint(
            'AttendanceSyncService: 🔐 Auth error, stopping sync. '
            'Will retry after re-login.',
          );
          await _updateRecordStatus(record.id, 'pending');
          break; // Stop sync loop, tunggu login ulang
        }

        final newRetryCount = record.retryCount + 1;
        if (newRetryCount >= _maxRetries) {
          debugPrint(
            'AttendanceSyncService: Record ${record.id} exceeded max retries.',
          );
          await _updateRecordStatus(
            record.id,
            'failed',
            retryCount: newRetryCount,
          );
        } else {
          await _updateRecordStatus(
            record.id,
            'pending',
            retryCount: newRetryCount,
          );
        }
      }
    }

    _isSyncing = false;
    onPendingCountChanged?.call();
    debugPrint('AttendanceSyncService: Sync completed.');
  }

  /// Reset semua record failed kembali ke pending (untuk dicoba ulang)
  Future<void> _resetFailedRecords() async {
    final records = await _loadRecords();
    bool changed = false;
    for (int i = 0; i < records.length; i++) {
      if (records[i].status == 'failed' || records[i].status == 'syncing') {
        records[i] = records[i].copyWith(status: 'pending', retryCount: 0);
        changed = true;
      }
    }
    if (changed) await _saveRecords(records);
  }

  // ============ Query ============

  /// Jumlah absensi yang masih pending
  Future<int> getPendingCount() async {
    final records = await _loadRecords();
    return records
        .where((r) => r.status == 'pending' || r.status == 'failed')
        .length;
  }

  /// Ambil semua record pending
  Future<List<PendingAttendanceModel>> getPendingRecords() async {
    return _loadRecords();
  }

  // ============ Private Methods ============

  Future<List<PendingAttendanceModel>> _loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_pendingKey);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((e) => PendingAttendanceModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('AttendanceSyncService: Failed to load records: $e');
      return [];
    }
  }

  Future<void> _saveRecords(List<PendingAttendanceModel> records) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = records.map((r) => r.toMap()).toList();
      await prefs.setString(_pendingKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('AttendanceSyncService: Failed to save records: $e');
    }
  }

  Future<void> _updateRecordStatus(
    String id,
    String status, {
    int? retryCount,
  }) async {
    final records = await _loadRecords();
    final index = records.indexWhere((r) => r.id == id);
    if (index == -1) return;

    records[index] = records[index].copyWith(
      status: status,
      retryCount: retryCount,
    );
    await _saveRecords(records);
  }

  Future<void> _removeRecord(String id) async {
    final records = await _loadRecords();
    records.removeWhere((r) => r.id == id);
    await _saveRecords(records);
  }

  Future<void> _deletePhotoFile(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('AttendanceSyncService: Deleted photo: $photoPath');
      }
    } catch (e) {
      debugPrint('AttendanceSyncService: Failed to delete photo: $e');
    }
  }
}
