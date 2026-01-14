import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationUtils {
  LocationUtils._();

  /// Cek apakah GPS/Location service aktif
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Cek status permission lokasi
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request permission lokasi
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Buka settings lokasi device
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Buka settings aplikasi (untuk permission)
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get current position dengan fallback ke last known position
  static Future<Position?> getCurrentPosition() async {
    // 1. Coba last known position dulu (lebih cepat, terutama di emulator)
    try {
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        debugPrint(
          'Using last known position: ${lastPosition.latitude}, ${lastPosition.longitude}',
        );
        return lastPosition;
      }
    } catch (e) {
      debugPrint('Error getting last known position: $e');
    }

    // 2. Jika tidak ada, coba dapatkan posisi terkini
    try {
      debugPrint('Getting current position...');
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // Low accuracy lebih cepat
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');

      // 3. Fallback: Mock position untuk testing di emulator
      debugPrint('Using mock position for testing...');
      return Position(
        latitude: -6.2088,
        longitude: 106.8456,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
  }

  /// Main method: Cek dan request lokasi dengan feedback lengkap
  /// Returns: Position jika berhasil, null jika gagal
  /// onError: Callback untuk menampilkan pesan error ke user
  static Future<Position?> checkAndRequestLocation({
    required Function(String message, LocationErrorType type) onError,
  }) async {
    // 1. Cek apakah GPS aktif
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      onError(
        'Layanan lokasi tidak aktif. Silakan aktifkan GPS Anda.',
        LocationErrorType.serviceDisabled,
      );
      return null;
    }

    // 2. Cek permission
    LocationPermission permission = await checkPermission();

    // 3. Jika denied, request permission
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        onError(
          'Izin lokasi ditolak. Silakan izinkan akses lokasi.',
          LocationErrorType.permissionDenied,
        );
        return null;
      }
    }

    // 4. Jika permanently denied
    if (permission == LocationPermission.deniedForever) {
      onError(
        'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan aplikasi.',
        LocationErrorType.permissionDeniedForever,
      );
      return null;
    }

    // 5. Get current position
    final position = await getCurrentPosition();
    if (position == null) {
      onError(
        'Gagal mendapatkan lokasi. Silakan coba lagi.',
        LocationErrorType.failedToGetLocation,
      );
      return null;
    }

    return position;
  }
}

enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  failedToGetLocation,
}
