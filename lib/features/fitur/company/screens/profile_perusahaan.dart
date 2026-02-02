import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/utils/image_url_extension.dart';
import 'package:hrd_app/core/widgets/skeleton_widget.dart';
import 'package:hrd_app/data/services/employee_service.dart';

class ProfilePerusahaanScreen extends StatefulWidget {
  const ProfilePerusahaanScreen({super.key});

  @override
  State<ProfilePerusahaanScreen> createState() =>
      _ProfilePerusahaanScreenState();
}

class _ProfilePerusahaanScreenState extends State<ProfilePerusahaanScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _companyData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await EmployeeService().getRelation(relation: 'COMPANY');
      if (mounted) {
        setState(() {
          _companyData =
              response['original']['records'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching company profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil Perusahaan Anda',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: _isLoading ? _buildSkeleton(colors) : _buildContent(colors),
      ),
    );
  }

  Widget _buildSkeleton(ThemeColors colors) {
    return SkeletonContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo skeleton
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colors.divider),
            ),
            child: Center(
              child: SkeletonBox(width: 200.w, height: 200.h, borderRadius: 8),
            ),
          ),
          SizedBox(height: 24.h),

          // Detail Perusahaan skeleton
          const SkeletonText(width: 120, height: 16),
          SizedBox(height: 16.h),
          const SkeletonText(width: 100, height: 12),
          SizedBox(height: 6.h),
          const SkeletonText(width: 150, height: 14),
          SizedBox(height: 16.h),
          const SkeletonText(width: 60, height: 12),
          SizedBox(height: 6.h),
          const SkeletonText(width: 250, height: 14),
          SizedBox(height: 6.h),
          const SkeletonText(width: 200, height: 14),
          SizedBox(height: 24.h),

          // Divider skeleton
          SkeletonBox(width: double.infinity, height: 1.h, borderRadius: 0),
          SizedBox(height: 24.h),

          // Kontak Perusahaan skeleton
          const SkeletonText(width: 130, height: 16),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonText(width: 50, height: 12),
                    SizedBox(height: 6.h),
                    const SkeletonText(width: 100, height: 14),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonText(width: 30, height: 12),
                    SizedBox(height: 6.h),
                    const SkeletonText(width: 80, height: 14),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const SkeletonText(width: 40, height: 12),
          SizedBox(height: 6.h),
          const SkeletonText(width: 180, height: 14),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    final companyName = _companyData?['company_name'] as String? ?? '-';
    final companyLogo = _companyData?['company_logo'] as String?;
    final companyAddress = _companyData?['company_address'] as String? ?? '-';
    final emailCompany = _companyData?['email_company'] as String? ?? '-';
    final phoneCompany = _companyData?['phone_company'] as String? ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Logo Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colors.divider),
          ),
          child: Center(
            child: companyLogo.asFullImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      companyLogo.asFullImageUrl!,
                      width: 200.w,
                      height: 200.w,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200.w,
                          height: 200.w,
                          color: colors.divider,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: colors.primaryBlue,
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200.w,
                          height: 200.w,
                          color: colors.divider,
                          child: Icon(
                            Icons.business,
                            size: 80.sp,
                            color: colors.textSecondary,
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 200.w,
                    height: 200.w,
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.business,
                      size: 80.sp,
                      color: colors.textSecondary,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 16.h),

        // Detail Perusahaan Section
        Text(
          'Detail Perusahaan',
          style: AppTextStyles.bodySemiBold(colors.textPrimary),
        ),
        SizedBox(height: 12.h),
        _buildInfoRow(colors, 'Nama Perusahaan', companyName),
        SizedBox(height: 12.h),
        _buildInfoRow(colors, 'Alamat', companyAddress),
        SizedBox(height: 12.h),

        // Divider
        Divider(color: colors.divider, thickness: 1.h),
        SizedBox(height: 12.h),

        // Kontak Perusahaan Section
        Text(
          'Kontak Perusahaan',
          style: AppTextStyles.bodySemiBold(colors.textPrimary),
        ),
        SizedBox(height: 10.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInfoRow(colors, 'Telepon', phoneCompany)),
            // Expanded(child: _buildInfoRow(colors, 'Faks', '-')),
          ],
        ),
        SizedBox(height: 10.h),
        _buildInfoRow(colors, 'Email', emailCompany),
        SizedBox(height: 16.h),

        // Bottom Divider
        Divider(color: colors.divider, thickness: 1.h),
      ],
    );
  }

  Widget _buildInfoRow(ThemeColors colors, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(colors.textSecondary)),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.body(colors.textPrimary, fontSize: 13.sp),
        ),
      ],
    );
  }
}
