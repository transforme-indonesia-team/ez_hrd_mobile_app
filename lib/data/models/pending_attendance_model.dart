import 'dart:convert';

class PendingAttendanceModel {
  final String id;
  final double latitude;
  final double longitude;
  final String photoPath;
  final String absentTime;
  final String status; // pending, syncing, failed
  final String createdAt;
  final int retryCount;

  const PendingAttendanceModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.photoPath,
    required this.absentTime,
    required this.status,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'photo_path': photoPath,
      'absent_time': absentTime,
      'status': status,
      'created_at': createdAt,
      'retry_count': retryCount,
    };
  }

  factory PendingAttendanceModel.fromMap(Map<String, dynamic> map) {
    return PendingAttendanceModel(
      id: map['id']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      photoPath: map['photo_path']?.toString() ?? '',
      absentTime: map['absent_time']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['created_at']?.toString() ?? '',
      retryCount: (map['retry_count'] as int?) ?? 0,
    );
  }

  String toJsonString() => jsonEncode(toMap());

  factory PendingAttendanceModel.fromJsonString(String json) {
    return PendingAttendanceModel.fromMap(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  PendingAttendanceModel copyWith({String? status, int? retryCount}) {
    return PendingAttendanceModel(
      id: id,
      latitude: latitude,
      longitude: longitude,
      photoPath: photoPath,
      absentTime: absentTime,
      status: status ?? this.status,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
