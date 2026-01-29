import 'package:hrd_app/data/models/leave_employee_model.dart';
import 'package:hrd_app/data/models/pagination_model.dart';

/// Model untuk response list cuti dari API
class LeaveListResponse {
  final int code;
  final bool status;
  final String message;
  final LeaveRecords? records;

  const LeaveListResponse({
    required this.code,
    required this.status,
    required this.message,
    this.records,
  });

  factory LeaveListResponse.fromJson(Map<String, dynamic> json) {
    return LeaveListResponse(
      code: json['code'] as int? ?? 0,
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      records: json['records'] != null
          ? LeaveRecords.fromJson(json['records'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'status': status,
      'message': message,
      'records': records?.toJson(),
    };
  }

  /// Check apakah response sukses
  bool get isSuccess => status && code == 200;

  /// Get list items, return empty list jika null
  List<LeaveEmployeeModel> get items => records?.items ?? [];

  /// Get pagination, return default jika null
  PaginationModel get pagination =>
      records?.pagination ??
      const PaginationModel(
        totalData: 0,
        totalPages: 1,
        currentPage: 1,
        pageSize: 10,
      );

  /// Check apakah data kosong
  bool get isEmpty => items.isEmpty;

  /// Check apakah ada data
  bool get isNotEmpty => items.isNotEmpty;
}

/// Model untuk records (berisi items dan pagination)
class LeaveRecords {
  final List<LeaveEmployeeModel> items;
  final PaginationModel pagination;

  const LeaveRecords({required this.items, required this.pagination});

  factory LeaveRecords.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];

    return LeaveRecords(
      items: itemsList
          .map(
            (item) => LeaveEmployeeModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : const PaginationModel(
              totalData: 0,
              totalPages: 1,
              currentPage: 1,
              pageSize: 10,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
