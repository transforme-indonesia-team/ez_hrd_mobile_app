import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/data/models/payroll_detail_model.dart';
import 'package:intl/intl.dart';

class DetailSlipGajiScreen extends StatelessWidget {
  final PayrollDetailModel payrollDetail;

  const DetailSlipGajiScreen({super.key, required this.payrollDetail});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final data = payrollDetail.data;

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
          'Slip Gaji ${payrollDetail.displayPeriod}',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: data == null
          ? Center(
              child: Text(
                'Data tidak tersedia',
                style: AppTextStyles.body(colors.textSecondary),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Employee Info Card
                  _buildEmployeeInfoCard(colors, data),
                  SizedBox(height: 12.h),

                  // Salary Summary Card
                  _buildSalarySummaryCard(colors, data),
                  SizedBox(height: 12.h),

                  // Allowances Section
                  if (data.allowances.isNotEmpty) ...[
                    _buildSectionTitle(colors, 'Tunjangan'),
                    SizedBox(height: 6.h),
                    _buildAllowancesCard(colors, data),
                    SizedBox(height: 12.h),
                  ],

                  // Deductions & Tax Info Combined Card
                  _buildDeductionsAndTaxCard(colors, data),
                  SizedBox(height: 12.h),

                  // Tax Detail Card
                  _buildTaxDetailCard(colors, data),
                  SizedBox(height: 12.h),

                  // Bank Info Card
                  _buildBankInfoCard(colors, data),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(ThemeColors colors, String title) {
    return Text(title, style: AppTextStyles.caption(colors.textPrimary));
  }

  Widget _buildEmployeeInfoCard(ThemeColors colors, PayrollData data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(colors, 'Nama', data.employeeName ?? '-'),
          _buildDivider(colors),
          _buildInfoRow(colors, 'NIK', data.employeeCode ?? '-'),
          _buildDivider(colors),
          _buildInfoRow(
            colors,
            'Jabatan',
            data.positionOrganizationName ?? '-',
          ),
          _buildDivider(colors),
          _buildInfoRow(colors, 'Cost Center', data.costCenterName ?? '-'),
          _buildDivider(colors),
          _buildInfoRow(colors, 'Status Pajak', data.taxStatus ?? '-'),
        ],
      ),
    );
  }

  Widget _buildSalarySummaryCard(ThemeColors colors, PayrollData data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Gaji',
            style: AppTextStyles.bodySemiBold(colors.primaryBlue),
          ),
          SizedBox(height: 8.h),
          _buildSalaryRow(colors, 'Gaji Pokok', data.basicSalary),
          _buildSalaryRow(colors, 'Total Pendapatan', data.totalEarning),
          _buildSalaryRow(colors, 'Gaji Kotor', data.grossSalary),
          _buildSalaryRow(
            colors,
            'Total Potongan',
            data.totalDeductions,
            isDeduction: true,
          ),
          const Divider(),
          _buildSalaryRow(
            colors,
            'Gaji Bersih',
            data.netSalary,
            isBold: true,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAllowancesCard(ThemeColors colors, PayrollData data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < data.allowances.length; i++) ...[
            _buildItemRow(
              colors,
              data.allowances[i].allowanceName ?? '-',
              data.allowances[i].allowanceAmount,
            ),
            if (i < data.allowances.length - 1) _buildDivider(colors),
          ],
        ],
      ),
    );
  }

  Widget _buildDeductionsAndTaxCard(ThemeColors colors, PayrollData data) {
    // Calculate grand total (deductions + tax)
    final totalDeductions = (data.subTotalDeductions ?? 0).toDouble();
    final totalTax = (data.totalTax ?? 0).toDouble();
    final grandTotal = totalDeductions + totalTax;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Potongan',
            style: AppTextStyles.bodySemiBold(colors.textPrimary),
          ),
          SizedBox(height: 8.h),

          // Deduction items
          for (int i = 0; i < data.deductions.length; i++) ...[
            _buildItemRow(
              colors,
              data.deductions[i].deductionName ?? '-',
              data.deductions[i].deductionAmount,
              isDeduction: true,
            ),
            _buildDivider(colors),
          ],

          // Tax as a deduction item
          if (data.totalTax != null && data.totalTax! > 0) ...[
            _buildItemRow(
              colors,
              'Pajak (PPh 21)',
              data.totalTax,
              isDeduction: true,
            ),
            _buildDivider(colors),
          ],

          // Grand total
          _buildItemRow(
            colors,
            'Total Potongan',
            grandTotal,
            isDeduction: true,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTaxDetailCard(ThemeColors colors, PayrollData data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Pajak',
            style: AppTextStyles.bodySemiBold(colors.textPrimary),
          ),
          SizedBox(height: 8.h),
          _buildItemRow(colors, 'Tunjangan Pajak', data.totalTaxAllowance),
          _buildDivider(colors),
          _buildItemRow(
            colors,
            'Pajak Ditanggung Perusahaan',
            data.totalTaxBorneByCompany,
          ),
          _buildDivider(colors),
          _buildItemRow(
            colors,
            'Denda Pajak Ditanggung Perusahaan',
            data.totalTaxPenaltyBorneByCompany,
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfoCard(ThemeColors colors, PayrollData data) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Bank',
            style: AppTextStyles.bodySemiBold(colors.textPrimary),
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(colors, 'Bank', data.employeeBankName ?? '-'),
          _buildDivider(colors),
          _buildInfoRow(
            colors,
            'Nama Rekening',
            data.bankAccountNameEmployee ?? '-',
          ),
          _buildDivider(colors),
          _buildInfoRow(
            colors,
            'No. Rekening',
            data.bankAccountNumberEmployee ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeColors colors, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption(colors.textSecondary)),
          Text(value, style: AppTextStyles.caption(colors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildSalaryRow(
    ThemeColors colors,
    String label,
    num? amount, {
    bool isDeduction = false,
    bool isBold = false,
    bool isHighlight = false,
  }) {
    final formattedAmount = _formatCurrency(amount);
    final displayAmount = isDeduction ? '- $formattedAmount' : formattedAmount;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTextStyles.captionMedium(colors.textPrimary)
                : AppTextStyles.caption(colors.textSecondary),
          ),
          Text(
            displayAmount,
            style: isBold
                ? AppTextStyles.captionMedium(
                    isHighlight ? colors.primaryBlue : colors.textPrimary,
                  )
                : AppTextStyles.caption(
                    isDeduction ? colors.error : colors.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(
    ThemeColors colors,
    String label,
    num? amount, {
    bool isDeduction = false,
    bool isBold = false,
  }) {
    final formattedAmount = _formatCurrency(amount);
    final displayAmount = isDeduction ? '- $formattedAmount' : formattedAmount;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: isBold
                  ? AppTextStyles.captionMedium(colors.textPrimary)
                  : AppTextStyles.caption(colors.textPrimary),
            ),
          ),
          Text(
            displayAmount,
            style: isBold
                ? AppTextStyles.captionMedium(
                    isDeduction ? colors.error : colors.textPrimary,
                  )
                : AppTextStyles.caption(
                    isDeduction ? colors.error : colors.textSecondary,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeColors colors) {
    return Divider(color: colors.divider.withValues(alpha: 0.5), height: 10.h);
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return 'Rp 0';
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(amount)}';
  }
}
