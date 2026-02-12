/// Model untuk area lokasi kehadiran (titik koordinat + radius)
class LocationAreaModel {
  final String id;
  final String areaName;
  final double lat;
  final double lng;
  final double maxRadiusKm;
  final String? attendanceLocationId;

  const LocationAreaModel({
    required this.id,
    required this.areaName,
    required this.lat,
    required this.lng,
    required this.maxRadiusKm,
    this.attendanceLocationId,
  });

  /// Radius dalam meter (untuk Google Maps Circle & Geolocator)
  double get maxRadiusMeters => maxRadiusKm * 1000;

  factory LocationAreaModel.fromJson(Map<String, dynamic> json) {
    return LocationAreaModel(
      id: json['id']?.toString() ?? '',
      areaName: json['area_name']?.toString() ?? '',
      lat: double.tryParse(json['lat_area']?.toString() ?? '') ?? 0,
      lng: double.tryParse(json['long_area']?.toString() ?? '') ?? 0,
      maxRadiusKm:
          double.tryParse(json['max_radius_area']?.toString() ?? '') ?? 0,
      attendanceLocationId: json['attendance_location_id']?.toString(),
    );
  }
}

/// Model untuk data lokasi kehadiran karyawan (berisi daftar area)
class AttendanceLocationModel {
  final String id;
  final String startDate;
  final String endDate;
  final String employeeId;
  final String attendanceLocationId;
  final String attendanceLocationName;
  final List<LocationAreaModel> locationAreas;

  const AttendanceLocationModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.employeeId,
    required this.attendanceLocationId,
    required this.attendanceLocationName,
    required this.locationAreas,
  });

  /// Cek apakah lokasi ini aktif hari ini
  bool get isActiveToday {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      return !today.isBefore(start) && !today.isAfter(end);
    } catch (_) {
      return false;
    }
  }

  factory AttendanceLocationModel.fromJson(Map<String, dynamic> json) {
    final areaList = json['locationArea'] as List<dynamic>? ?? [];

    return AttendanceLocationModel(
      id: json['id']?.toString() ?? '',
      startDate: json['start_date_employee_attendance']?.toString() ?? '',
      endDate: json['end_date_employee_attendance']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      attendanceLocationId: json['attendance_location_id']?.toString() ?? '',
      attendanceLocationName:
          json['attendance_location_name']?.toString() ?? '',
      locationAreas: areaList
          .map((e) => LocationAreaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Parse dari response API lengkap ke list model
  /// Response format: { "records": { "attendance_location": [...] } }
  static List<AttendanceLocationModel> parseFromApiResponse(
    Map<String, dynamic> response,
  ) {
    try {
      final original = response['original'] as Map<String, dynamic>?;
      final records = original?['records'] as Map<String, dynamic>?;
      final locations = records?['attendance_location'] as List<dynamic>? ?? [];

      return locations
          .map(
            (e) => AttendanceLocationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}
