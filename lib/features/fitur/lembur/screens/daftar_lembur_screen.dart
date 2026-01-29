import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/models/overtime_employee_model.dart';
import 'package:hrd_app/data/services/overtime_service.dart';
import 'package:hrd_app/features/fitur/lembur/screens/detail_lembur_screen.dart';
import 'package:hrd_app/features/fitur/lembur/screens/form_lembur_screen.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/lembur_filter_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/overtime_request_card.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/pagination_widget.dart';

class DaftarLemburScreen extends StatefulWidget {
  const DaftarLemburScreen({super.key});

  @override
  State<DaftarLemburScreen> createState() => _DaftarLemburScreenState();
}

class _DaftarLemburScreenState extends State<DaftarLemburScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  List<OvertimeEmployeeModel> _requests = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await OvertimeService().getOvertimeEmployee(
        page: _currentPage,
        limit: 10,
      );

      final recordsRaw = response['original']['records'];

      // Handle case where records is empty list [] instead of Map
      if (recordsRaw == null || recordsRaw is List) {
        setState(() {
          _isLoading = false;
          _requests = [];
          _totalItems = 0;
          _totalPages = 1;
          _errorMessage = null;
        });
        return;
      }

      final records = recordsRaw as Map<String, dynamic>;
      final items = records['items'] as List<dynamic>? ?? [];
      final pagination = records['pagination'] as Map<String, dynamic>?;

      setState(() {
        _requests = items
            .map(
              (e) => OvertimeEmployeeModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        _totalItems = pagination?['total_data'] as int? ?? 0;
        _totalPages = pagination?['total_pages'] as int? ?? 1;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('Error fetching overtime list: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Terjadi kesalahan saat memuat data';
        });
      }
    }
  }

  void _showFilterBottomSheet() {
    LemburFilterBottomSheet.show(
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
      MaterialPageRoute(builder: (context) => const FormLemburScreen()),
    );

    // Refresh data if form was submitted successfully
    if (result == true && mounted) {
      _currentPage = 1; // Reset to first page
      _fetchData();
    }
  }

  Future<void> _navigateToEdit(OvertimeEmployeeModel request) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FormLemburScreen(existingOvertime: request),
      ),
    );

    // Refresh data if overtime was updated successfully
    if (result == true && mounted) {
      _fetchData();
    }
  }

  Future<void> _navigateToDetail(OvertimeEmployeeModel request) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (contect) => DetailLemburScreen(detailOvertime: request),
      ),
    );
    if (result == true && mounted) {
      _fetchData();
    }
  }

  bool get _hasActiveFilter =>
      _filterStartDate != null || _filterEndDate != null;

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daftar Lembur',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _hasActiveFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _hasActiveFilter ? colors.primaryBlue : colors.textPrimary,
            ),
            onPressed: _showFilterBottomSheet,
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
        child: Text(
          _errorMessage!,
          style: AppTextStyles.body(colors.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _requests.isEmpty
              ? _buildEmptyState(colors)
              : ListView.builder(
                  padding: EdgeInsets.only(top: 8.h),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    return OvertimeRequestCard(
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

  Widget _buildEmptyState(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80.sp, color: colors.divider),
          SizedBox(height: 16.h),
          Text(
            'Belum ada permintaan lembur',
            style: AppTextStyles.h4(colors.textSecondary),
          ),
        ],
      ),
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
