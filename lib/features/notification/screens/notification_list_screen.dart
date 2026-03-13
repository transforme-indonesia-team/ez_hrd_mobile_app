import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/models/notification_model.dart';
import 'package:hrd_app/data/models/leave_employee_model.dart';
import 'package:hrd_app/data/models/overtime_employee_model.dart';
import 'package:hrd_app/data/services/notification_service.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/screens/daftar_koreksi_kehadiran_screen.dart';
import 'package:hrd_app/data/services/attendance_correction_service.dart';
import 'package:hrd_app/data/services/leave_service.dart';
import 'package:hrd_app/data/services/overtime_service.dart';
import 'package:hrd_app/features/fitur/koreksi_kehadiran/screens/detail_koreksi_kehadiran_screen.dart';
import 'package:hrd_app/features/fitur/cuti/screens/detail_cuti_screen.dart';
import 'package:hrd_app/features/fitur/lembur/screens/detail_lembur_screen.dart';
import 'package:hrd_app/features/notification/widgets/notification_item_card.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/features/fitur/permohonan/screens/permohonan_karyawan_screen.dart';

class NotificationListScreen extends StatefulWidget {
  final NotificationCategory category;
  final String notifType; // 'REQUEST' or 'APPROVAL'

  const NotificationListScreen({
    super.key,
    required this.category,
    required this.notifType,
  });

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen>
    with SingleTickerProviderStateMixin {
  late List<NotificationItem> _items;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.category.items);

    if (widget.notifType == 'APPROVAL') {
      _tabController = TabController(length: 2, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _markAsRead(NotificationItem item) async {
    if (item.isRead || item.id == null) return;

    try {
      await NotificationService().markAsRead(notificationIds: [item.id!]);

      if (mounted) {
        setState(() {
          final index = _items.indexWhere((i) => i.id == item.id);
          if (index != -1) {
            _items[index] = item.copyWithRead();
          }
        });
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  void _onItemTap(NotificationItem item) async {
    await _markAsRead(item);
    if (mounted) _navigateToDetail(item);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isApproval = widget.notifType == 'APPROVAL';

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category.label,
          style: AppTextStyles.h3(colors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
        bottom: isApproval
            ? PreferredSize(
                preferredSize: Size.fromHeight(44.h),
                child: TabBar(
                  controller: _tabController,
                  labelColor: colors.primaryBlue,
                  unselectedLabelColor: colors.textSecondary,
                  indicatorColor: colors.primaryBlue,
                  indicatorWeight: 2.5,
                  tabs: const [
                    Tab(text: 'Permintaan Baru'),
                    Tab(text: 'Riwayat'),
                  ],
                ),
              )
            : null,
      ),
      body: isApproval
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildList(colors, isNewRequest: true),
                _buildList(colors, isNewRequest: false),
              ],
            )
          : _buildList(colors, isNewRequest: null),
    );
  }

  Widget _buildList(ThemeColors colors, {bool? isNewRequest}) {
    List<NotificationItem> filteredItems = _items;

    if (isNewRequest != null) {
      filteredItems = _items.where((item) {
        final status = item.status?.toUpperCase() ?? '';
        final isPending = status == 'PENDING' || status == 'UNVERIFIED';
        return isNewRequest ? isPending : !isPending;
      }).toList();
    }

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 60.sp, color: colors.divider),
            SizedBox(height: 12.h),
            Text(
              'Tidak ada data',
              style: AppTextStyles.body(colors.textSecondary),
            ),
          ],
        ),
      );
    }

    final listView = ListView.builder(
      padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return NotificationItemCard(
          item: item,
          showApprovalActions: isNewRequest == true,
          onTap: () => _onItemTap(item),
          onApprovalAction: (status) => _handleInlineApproval(item, status),
        );
      },
    );

    if (isNewRequest == true && widget.notifType == 'APPROVAL') {
      return Column(
        children: [
          Expanded(child: listView),
          _buildBatchApprovalButton(colors),
        ],
      );
    }

    return listView;
  }

  Widget _buildBatchApprovalButton(ThemeColors colors) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 44.h,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PermohonanKaryawanScreen(
                    initialTab: 1, // 1 = Persetujuan
                    initialTipePermintaan: widget.category.label,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primaryBlue,
              side: BorderSide(color: colors.primaryBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Persetujuan Massal',
              style: AppTextStyles.bodySemiBold(colors.primaryBlue),
            ),
          ),
        ),
      ),
    );
  }

  bool _isProcessingApproval = false;

  Future<void> _handleInlineApproval(
    NotificationItem item,
    String status,
  ) async {
    if (_isProcessingApproval) return;

    String remark = '';

    if (status != 'APPROVE') {
      final bool? isProceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final textController = TextEditingController();
          final colors = context.colors;

          return AlertDialog(
            backgroundColor: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: Text('Catatan', style: AppTextStyles.h4(colors.textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Berikan catatan untuk karyawan',
                  style: AppTextStyles.body(colors.textSecondary),
                ),
                SizedBox(height: 16.h),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.divider),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: TextField(
                    controller: textController,
                    maxLines: 3,
                    minLines: 1,
                    style: AppTextStyles.body(colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Masukkan alasan Anda',
                      hintStyle: AppTextStyles.body(
                        colors.textSecondary.withValues(alpha: 0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Batalkan',
                  style: AppTextStyles.bodyMedium(colors.primaryBlue),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  remark = textController.text.trim();
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Simpan',
                  style: AppTextStyles.bodyMedium(Colors.white),
                ),
              ),
            ],
          );
        },
      );

      if (isProceed != true) return;
    }

    setState(() => _isProcessingApproval = true);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      Map<String, dynamic>? response;

      switch (widget.category.key) {
        case 'attendance_correction_request':
          if (item.id != null) {
            response = await AttendanceCorrectionService()
                .approvalAttendanceCorrection(
                  attendanceCorrectionId: item.id!,
                  status: status,
                  remark: remark,
                );
          }
          break;
        case 'leave_employee':
          if (item.id != null) {
            response = await LeaveService().approvalLeaveEmployee(
              leaveId: item.id!,
              status: status,
              remark: remark,
            );
          }
          break;
        case 'leave_cancellation':
          if (item.leaveCancellationId != null) {
            response = await LeaveService().approvalLeaveCancellation(
              leaveCancellationId: item.leaveCancellationId!,
              status: status,
              remark: remark,
            );
          }
          break;
        case 'overtime_employee':
          if (item.id != null) {
            response = await OvertimeService().approvalOvertime(
              overtimeId: item.id!,
              status: status,
              remark: remark,
            );
          }
          break;
      }

      if (mounted && response != null) {
        Navigator.pop(context); // Close loading

        final records = response['original'];
        final isSuccess = records['status'] == true || records['code'] == 200;

        if (isSuccess) {
          context.showSuccessSnackbar(
            records['message'] ?? 'Berhasil memproses data',
          );

          setState(() {
            final index = _items.indexWhere((i) => i.id == item.id);
            if (index != -1) {
              String newStatus;
              if (status == 'APPROVE') {
                newStatus = 'APPROVED';
              } else if (status == 'REJECT')
                newStatus = 'REJECTED';
              else if (status == 'REVISE')
                newStatus = 'REVISED';
              else
                newStatus = status;

              _items[index] = _items[index].copyWithStatus(newStatus);
            }
          });
        } else {
          context.showErrorSnackbar(
            records['message'] ?? 'Gagal memproses data',
          );
        }
      } else if (mounted) {
        Navigator.pop(context); // Close loading
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        context.showErrorSnackbar('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isProcessingApproval = false);
    }
  }

  void _navigateToDetail(NotificationItem item) {
    final isApprovalMode = widget.notifType == 'APPROVAL';

    switch (widget.category.key) {
      case 'attendance_correction_request':
        if (item.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailKoreksiKehadiranScreen(
                correctionId: item.id!,
                isApprovalMode: isApprovalMode,
              ),
            ),
          );
        }
        break;
      case 'leave_employee':
        if (item.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailCutiScreen(
                detailLeave: LeaveEmployeeModel(id: item.id!),
                isApprovalMode: isApprovalMode,
                isCancellation: false,
              ),
            ),
          );
        }
        break;
      case 'leave_cancellation':
        if (item.leaveEmployeeId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailCutiScreen(
                detailLeave: LeaveEmployeeModel(id: item.leaveEmployeeId!),
                isApprovalMode: isApprovalMode,
                isCancellation: true,
              ),
            ),
          );
        }
        break;
      case 'overtime_employee':
        if (item.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailLemburScreen(
                detailOvertime: OvertimeEmployeeModel(id: item.id!),
                isApprovalMode: isApprovalMode,
              ),
            ),
          );
        }
        break;
    }
  }

  // ignore: unused_element
  Widget _buildShowAllButton(ThemeColors colors) {
    return InkWell(
      onTap: () => _navigateToAllList(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(top: BorderSide(color: colors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.open_in_new, size: 16.sp, color: colors.textSecondary),
            SizedBox(width: 8.w),
            Text(
              'Tampilkan Semua',
              style: AppTextStyles.bodyMedium(colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAllList() {
    switch (widget.category.key) {
      case 'attendance_correction_request':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DaftarKoreksiKehadiranScreen(),
          ),
        );
        break;
      default:
        break;
    }
  }
}
