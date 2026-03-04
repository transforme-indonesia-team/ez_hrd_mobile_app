import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/core/widgets/empty_state_widget.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/data/models/payroll_detail_model.dart';
import 'package:hrd_app/data/models/payslip_model.dart';
import 'package:hrd_app/data/services/slip_gaji_service.dart';
import 'package:hrd_app/features/fitur/gaji/screens/detail_slip_gaji_screen.dart';
import 'package:hrd_app/features/fitur/gaji/widgets/password_dialog.dart';
import 'package:hrd_app/features/fitur/gaji/widgets/payslip_card.dart';

class SlipGajiScreen extends StatefulWidget {
  const SlipGajiScreen({super.key});

  @override
  State<SlipGajiScreen> createState() => _SlipGajiScreenState();
}

class _SlipGajiScreenState extends State<SlipGajiScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<PayslipModel> _payslips = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await SlipGajiService().paySLipEmployee();

      // get() returns {headers, original, exception} structure
      final originalData = response['original'] as Map<String, dynamic>?;
      final recordsData = originalData?['records'];
      List<dynamic> records = [];

      if (recordsData is List) {
        records = recordsData;
      }

      debugPrint('DEBUG-SLIP: Parsed ${records.length} records');

      _payslips = records
          .map((e) => PayslipModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching payslips: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data slip gaji';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
          'Riwayat Gaji',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(ThemeColors colors) {
    if (_isLoading) {
      return _buildSkeletonList(colors);
    }

    if (_errorMessage != null) {
      return EmptyStateWidget(
        message: _errorMessage!,
        icon: Icons.error_outline,
        onRetry: _fetchData,
      );
    }

    // Content with info card at top
    return Column(
      children: [
        // Info card always visible
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          child: _buildInfoCard(colors),
        ),

        // List or empty state
        Expanded(
          child: _payslips.isEmpty
              ? const EmptyStateWidget(
                  message: 'Tidak ada data untuk\nditampilkan',
                  icon: Icons.description_outlined,
                )
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  color: colors.primaryBlue,
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _payslips.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      return PayslipCard(
                        payslip: _payslips[index],
                        onTap: () => _onPayslipTap(_payslips[index]),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(ThemeColors colors) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kata Sandi Slip Gaji',
            style: AppTextStyles.bodySemiBold(colors.primaryBlue),
          ),
          SizedBox(height: 4.h),
          Text(
            'Untuk membuka slip gaji, gunakan password login atau buat password slip gaji yang baru',
            style: AppTextStyles.caption(colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _onPayslipTap(PayslipModel payslip) async {
    // Show password dialog
    final result = await PasswordDialog.show(
      context: context,
      title: 'Masukkan Kata Sandi',
      subtitle: 'Untuk melihat slip gaji ${payslip.displayPeriod}',
      onSubmit: (password, passwordPayroll) async {
        // Check password via API
        try {
          final response = await SlipGajiService().checkPasswordPayroll(
            password: password,
            passwordPayroll: passwordPayroll,
          );

          debugPrint('DEBUG-SLIP: Password check response: $response');
          final originalData = response['original'] as Map<String, dynamic>?;
          final code = originalData?['code'] as int?;
          return code == 200;
        } catch (e) {
          debugPrint('Error checking password: $e');
          rethrow;
        }
      },
    );

    // If password correct, navigate to detail
    if (result == true && mounted) {
      _navigateToDetail(payslip);
    }
  }

  Future<void> _navigateToDetail(PayslipModel payslip) async {
    // Show loading
    final loadingDialogContext = context;
    showDialog(
      context: loadingDialogContext,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await SlipGajiService().payrollEmployeeDetail(
        employeeId: payslip.employeeId ?? '',
        employeeName: payslip.employeeName,
        periodMonth: payslip.periodMonth?.toString() ?? '',
        periodYear: payslip.periodYear?.toString() ?? '',
      );

      debugPrint('DEBUG-SLIP: Detail response: $response');

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(loadingDialogContext, rootNavigator: true).pop();

      // Handle both response structures (with or without 'original' wrapper)
      Map<String, dynamic>? records;
      if (response.containsKey('original')) {
        final originalData = response['original'] as Map<String, dynamic>?;
        records = originalData?['records'] as Map<String, dynamic>?;
      } else if (response.containsKey('records')) {
        records = response['records'] as Map<String, dynamic>?;
      }

      debugPrint('DEBUG-SLIP: Parsed records: $records');

      if (records != null) {
        final payrollDetail = PayrollDetailModel.fromJson(records);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailSlipGajiScreen(payrollDetail: payrollDetail),
          ),
        );
      } else {
        context.showErrorSnackbar('Data tidak ditemukan');
      }
    } catch (e) {
      debugPrint('DEBUG-SLIP: Error in navigateToDetail: $e');
      if (mounted) {
        // Close loading dialog safely
        Navigator.of(loadingDialogContext, rootNavigator: true).pop();

        String errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.replaceFirst('Exception: ', '');
        }
        context.showErrorSnackbar('Gagal memuat detail: $errorMsg');
      }
    }
  }

  Widget _buildSkeletonList(ThemeColors colors) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, __) => _buildSkeletonCard(colors),
    );
  }

  Widget _buildSkeletonCard(ThemeColors colors) {
    return SkeletonContainer(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            SkeletonBox(width: 48.w, height: 48.w, borderRadius: 8),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonText(width: 100.w, height: 16.h),
                  SizedBox(height: 6.h),
                  SkeletonText(width: 140.w, height: 14.h),
                ],
              ),
            ),
            SkeletonBox(width: 24.w, height: 24.w, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}
