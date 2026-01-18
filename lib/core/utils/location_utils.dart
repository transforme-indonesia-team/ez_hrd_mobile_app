import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrd_app/core/constants/app_constants.dart';

class LocationUtils {
  LocationUtils._();

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        return lastPosition;
      }
    } catch (e) {
      debugPrint('LocationUtils: Failed to get last known position: $e');
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: AppConstants.locationTimeoutSeconds),
        ),
      );
    } catch (e) {
      debugPrint('LocationUtils: Failed to get current position: $e');
      return null;
    }
  }

  static Future<Position?> checkAndRequestLocation({
    required Function(String message, LocationErrorType type) onError,
  }) async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      onError(
        'Layanan lokasi tidak aktif. Silakan aktifkan GPS Anda.',
        LocationErrorType.serviceDisabled,
      );
      return null;
    }

    LocationPermission permission = await checkPermission();

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

    if (permission == LocationPermission.deniedForever) {
      onError(
        'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan aplikasi.',
        LocationErrorType.permissionDeniedForever,
      );
      return null;
    }

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
