import 'package:geolocator/geolocator.dart';

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
    } catch (_) {}

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
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
