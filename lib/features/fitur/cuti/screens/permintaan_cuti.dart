import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/data/models/leave_employee_model.dart';
import 'package:hrd_app/data/services/leave_service.dart';
import 'package:hrd_app/features/fitur/cuti/screens/form_permintaan_cuti.dart';
import 'package:hrd_app/features/fitur/cuti/widgets/leave_request_card.dart';
import 'package:hrd_app/features/fitur/cuti/widgets/permintaan_cuti_filter_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/pagination_widget.dart';

class PermintaanCutiScreen extends StatefulWidget {
  const PermintaanCutiScreen({super.key});

  @override
  State<PermintaanCutiScreen> createState() => _PermintaanCutiScreenState();
}

class _PermintaanCutiScreenState extends State<PermintaanCutiScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  List<LeaveEmployeeModel> _requests = [];

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  bool get _hasActiveFilter =>
      _filterStartDate != null || _filterEndDate != null;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final response = await LeaveService().getLeaveEmployee(
        page: _currentPage,
        limit: 10,
      );

      final records = response['original']['records'];

      if (mounted) {
        setState(() {
          _isLoading = false;
          _requests = (records['items'] as List<dynamic>)
              .map((e) => LeaveEmployeeModel.fromJson(e))
              .toList();
          _totalItems = records['pagination']['total_data'] as int? ?? 0;
          _totalPages = records['pagination']['total_pages'] as int? ?? 1;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data: $e';
        });
      }
    }
  }

  void _showFilterBottomSheet() {
    PermintaanCutiFilterBottomSheet.show(
      context,
      startDate: _filterStartDate,
      endDate: _filterEndDate,
      onApply: (startDate, endDate) {
        setState(() {
          _filterStartDate = startDate;
          _filterEndDate = endDate;
        });
        // TODO: Apply filter to API call
      },
    );
  }

  Future<void> _navigateToForm() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const FormPermintaanCutiScreeen(),
      ),
    );

    if (result == true && mounted) {
      _currentPage = 1;
      _fetchData();
    }
  }

  Future<void> _navigateToEdit(LeaveEmployeeModel request) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormPermintaanCutiScreeen(existingLeave: request),
      ),
    );

    if (result == true && mounted) {
      _fetchData();
    }
  }

  Future<void> _navigateToDetail(LeaveEmployeeModel request) async {
    // TODO: Navigate to detail cuti screen
    // final result = await Navigator.push<bool>(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => DetailCutiScreen(detailLeave: request),
    //   ),
    // );

    // if (result == true && mounted) {
    //   _fetchData();
    // }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Daftar Cuti", style: AppTextStyles.h3(colors.textPrimary)),
        actions: [
          IconButton(
            icon: Icon(
              _hasActiveFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _hasActiveFilter ? colors.primaryBlue : colors.textPrimary,
            ),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
        ],
      ),
      body: _buildBody(colors),
      bottomNavigationBar: _buildBottomButton(colors),
    );
  }

  Widget _buildBody(ThemeColors colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: colors.textSecondary),
            SizedBox(height: 16.h),
            Text(
              _errorMessage!,
              style: AppTextStyles.body(colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _requests.isEmpty
              ? const EmptyStateWidget(
                  message: 'Belum ada permintaan cuti',
                  icon: Icons.calendar_month_outlined,
                )
              : ListView.builder(
                  padding: EdgeInsets.only(top: 8.h),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    return LeaveRequestCard(
                      request: _requests[index],
                      onTap: () {
                        _navigateToDetail(_requests[index]);
                      },
                      onEdit: _requests[index].isDraft
                          ? () => _navigateToEdit(_requests[index])
                          : null,
                    );
                  },
                ),
        ),
        if (_requests.isNotEmpty)
          PaginationWidget(
            currentPage: _currentPage,
            totalPages: _totalPages,
            totalItems: _totalItems,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
              _fetchData();
            },
          ),
      ],
    );
  }

  Widget _buildBottomButton(ThemeColors colors) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: colors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _navigateToForm,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Permintaan Baru',
            style: AppTextStyles.button(Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primaryBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ),
    );
  }
}
