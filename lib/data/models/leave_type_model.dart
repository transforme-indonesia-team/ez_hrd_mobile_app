/// Model untuk tipe cuti (leave type)
class LeaveTypeModel {
  final String id;
  final String? leaveName;
  final String? leaveCode;
  final String? dayCount;
  final String? leaveDayType;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final int? countLeave;
  final int? repeatPeriod;
  final String? leaveEntitlementPeriodBasedOn;
  final String? startPeriodLeave;
  final String? proportionalOn;
  final int? leaveAvailableAfter;
  final bool? leaveRepeated;
  final String? leaveValidEndPeriod;
  final String? leaveEndPeriod;
  final String? leaveEndYearPeriod;
  final String? leaveEntitlementAvailability;
  final bool? deductedLeave;

  const LeaveTypeModel({
    required this.id,
    this.leaveName,
    this.leaveCode,
    this.dayCount,
    this.leaveDayType,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.countLeave,
    this.repeatPeriod,
    this.leaveEntitlementPeriodBasedOn,
    this.startPeriodLeave,
    this.proportionalOn,
    this.leaveAvailableAfter,
    this.leaveRepeated,
    this.leaveValidEndPeriod,
    this.leaveEndPeriod,
    this.leaveEndYearPeriod,
    this.leaveEntitlementAvailability,
    this.deductedLeave,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'] as String,
      leaveName: json['leave_name'] as String?,
      leaveCode: json['leave_code'] as String?,
      dayCount: json['day_count'] as String?,
      leaveDayType: json['leave_day_type'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      countLeave: json['count_leave'] as int?,
      repeatPeriod: json['repeat_period'] as int?,
      leaveEntitlementPeriodBasedOn:
          json['leave_entitilement_period_based_on'] as String?,
      startPeriodLeave: json['start_period_leave'] as String?,
      proportionalOn: json['proportional_on'] as String?,
      leaveAvailableAfter: json['leave_available_after'] as int?,
      leaveRepeated: json['leave_repeated'] as bool?,
      leaveValidEndPeriod: json['leave_valid_end_period'] as String?,
      leaveEndPeriod: json['leave_end_period'] as String?,
      leaveEndYearPeriod: json['leave_end_year_period'] as String?,
      leaveEntitlementAvailability:
          json['leave_entitlement_availability'] as String?,
      deductedLeave: json['deducted_leave'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leave_name': leaveName,
      'leave_code': leaveCode,
      'day_count': dayCount,
      'leave_day_type': leaveDayType,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'count_leave': countLeave,
      'repeat_period': repeatPeriod,
      'leave_entitilement_period_based_on': leaveEntitlementPeriodBasedOn,
      'start_period_leave': startPeriodLeave,
      'proportional_on': proportionalOn,
      'leave_available_after': leaveAvailableAfter,
      'leave_repeated': leaveRepeated,
      'leave_valid_end_period': leaveValidEndPeriod,
      'leave_end_period': leaveEndPeriod,
      'leave_end_year_period': leaveEndYearPeriod,
      'leave_entitlement_availability': leaveEntitlementAvailability,
      'deducted_leave': deductedLeave,
    };
  }

  /// Display name untuk UI
  String get displayName => leaveName ?? '-';

  /// Display code untuk UI
  String get displayCode => leaveCode ?? '-';
}
