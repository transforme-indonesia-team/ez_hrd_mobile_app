import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class KontakScreen extends StatefulWidget {
  const KontakScreen({super.key});

  @override
  State<KontakScreen> createState() => _KontakScreenState();
}

class _KontakScreenState extends State<KontakScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _data = {
          'telepon': '083123456789',
          'ext': '-',
          'email': 'test@demo.com',
        };
      });
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
          'Kontak',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: _isLoading
            ? _buildSkeletonLoading(colors)
            : _buildContent(colors),
      ),
    );
  }

  Widget _buildContent(dynamic colors) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16.h,
        children: [
          _buildInfoRow(colors, 'Telepon / Ponsel', _data?['telepon']),
          _buildInfoRow(colors, 'Ext', _data?['ext']),
          _buildInfoRow(colors, 'Email', _data?['email'], isRequired: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    dynamic colors,
    String label,
    String? value, {
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: colors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value ?? '-',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: colors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoading(dynamic colors) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Shimmer.fromColors(
        baseColor: colors.divider,
        highlightColor: colors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20.h,
          children: List.generate(3, (index) => _buildSkeletonItem()),
        ),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: 180.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ],
    );
  }
}
