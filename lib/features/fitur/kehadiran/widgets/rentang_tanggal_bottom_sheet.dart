import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/format_date.dart';

class RentangTanggalBottomSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const RentangTanggalBottomSheet({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });

  static Future<DateTimeRange?> show(
    BuildContext context, {
    DateTime? initialStartDate,
    DateTime? initialEndDate,
  }) {
    return showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RentangTanggalBottomSheet(
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
      ),
    );
  }

  @override
  State<RentangTanggalBottomSheet> createState() =>
      _RentangTanggalBottomSheetState();
}

class _RentangTanggalBottomSheetState extends State<RentangTanggalBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _focusedDate;

  final List<String> _weekdays = [
    'Min',
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
  ];

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _focusedDate = _startDate != null
        ? DateTime(_startDate!.year, _startDate!.month)
        : DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _onDayTapped(DateTime day) {
    setState(() {
      if (_startDate == null) {
        _startDate = day;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        if (day.isBefore(_startDate!)) {
          _startDate = day;
        } else {
          _endDate = day;
        }
      } else if (_startDate != null && _endDate != null) {
        _startDate = day;
        _endDate = null;
      }
    });
  }

  void _changeMonth(int increment) {
    setState(() {
      _focusedDate = DateTime(
        _focusedDate.year,
        _focusedDate.month + increment,
      );
    });
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getRangeText() {
    if (_startDate == null) return 'Pilih Rentang Tanggal';
    final startStr = FormatDate.shortDateWithYear(_startDate!);
    if (_endDate == null) return startStr;
    final endStr = FormatDate.shortDateWithYear(_endDate!);
    return '$startStr - $endStr';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDate.year,
      _focusedDate.month,
    );
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);

    // get weekday for 1st day (1 = Monday, 7 = Sunday)
    // we want Sunday = 0, Monday = 1, ...
    int firstWeekday = firstDayOfMonth.weekday;
    if (firstWeekday == 7) firstWeekday = 0;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Title
          Center(
            child: Text(
              'Rentang Tanggal',
              style: AppTextStyles.bodySemiBold(
                colors.textPrimary,
                fontSize: 15.sp,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Month selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: colors.textPrimary,
                  size: 20.sp,
                ),
                onPressed: () => _changeMonth(-1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatMonthYear(_focusedDate),
                    style: AppTextStyles.bodyMedium(colors.textPrimary),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: colors.textPrimary,
                    size: 20.sp,
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: colors.textPrimary,
                  size: 20.sp,
                ),
                onPressed: () => _changeMonth(1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Weekdays header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTextStyles.xSmall(colors.textSecondary),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8.h),
          Divider(color: colors.divider, height: 1),
          SizedBox(height: 8.h),

          // Calendar Grid
          Container(
            color: colors.background,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.1,
                mainAxisSpacing: 4,
                crossAxisSpacing: 0,
              ),
              itemCount: 42, // 6 weeks
              itemBuilder: (context, index) {
                if (index < firstWeekday) {
                  return const SizedBox();
                }
                final dayNumber = index - firstWeekday + 1;
                if (dayNumber > daysInMonth) {
                  return const SizedBox();
                }

                final currentDate = DateTime(
                  _focusedDate.year,
                  _focusedDate.month,
                  dayNumber,
                );
                final isToday = DateUtils.isSameDay(
                  currentDate,
                  DateTime.now(),
                );

                bool isSelected = false;
                bool isStart = false;
                bool isEnd = false;
                bool isInRange = false;

                if (_startDate != null) {
                  isStart = DateUtils.isSameDay(currentDate, _startDate);
                  if (_endDate == null) {
                    isSelected = isStart;
                  } else {
                    isEnd = DateUtils.isSameDay(currentDate, _endDate);
                    isSelected = isStart || isEnd;
                    if (currentDate.isAfter(_startDate!) &&
                        currentDate.isBefore(_endDate!)) {
                      isInRange = true;
                    }
                  }
                }

                return GestureDetector(
                  onTap: () => _onDayTapped(currentDate),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primaryBlue
                          : isInRange
                          ? colors.primaryBlue.withOpacity(0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(color: colors.divider, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style:
                            AppTextStyles.small(
                              isSelected
                                  ? Colors.white
                                  : (isInRange || isToday)
                                  ? colors.textPrimary
                                  : colors.textSecondary,
                            ).copyWith(
                              fontWeight: (isSelected || isToday)
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),

          // Selected range container
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                _getRangeText(),
                style: AppTextStyles.smallMedium(colors.textPrimary),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Divider(color: colors.divider, height: 1),
          SizedBox(height: 16.h),

          // Selesai Button
          Container(
            height: 46.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors.buttonGradient),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (_startDate != null && _endDate != null) {
                    Navigator.pop(
                      context,
                      DateTimeRange(start: _startDate!, end: _endDate!),
                    );
                  } else if (_startDate != null) {
                    Navigator.pop(
                      context,
                      DateTimeRange(start: _startDate!, end: _startDate!),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Center(
                  child: Text(
                    'Selesai',
                    style: AppTextStyles.button(Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
        ],
      ),
    );
  }
}
