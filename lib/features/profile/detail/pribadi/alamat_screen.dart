import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:hrd_app/core/providers/auth_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/data/models/user_model.dart';
import 'package:provider/provider.dart';

class AlamatScreen extends StatelessWidget {
  const AlamatScreen({super.key});

  String _toTitleCase(String? text) {
    if (text == null || text.isEmpty) return '';

    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String _formatFullAddress({
    String? address,
    String? subdistrict,
    String? city,
    String? province,
    String? postalCode,
  }) {
    final parts = <String>[];

    if (address != null && address.isNotEmpty) {
      parts.add(_toTitleCase(address));
    }

    if (subdistrict != null && subdistrict.isNotEmpty) {
      parts.add('Kecamatan ${_toTitleCase(subdistrict)}');
    }

    if (city != null && city.isNotEmpty) {
      parts.add(_toTitleCase(city));
    }

    if (province != null && province.isNotEmpty) {
      if (postalCode != null && postalCode.isNotEmpty) {
        parts.add('${_toTitleCase(province)} $postalCode');
      } else {
        parts.add(_toTitleCase(province));
      }
    } else if (postalCode != null && postalCode.isNotEmpty) {
      parts.add(postalCode);
    }

    return parts.isNotEmpty ? parts.join(', ') : '-';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Alamat', style: AppTextStyles.h3(colors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: _buildContent(colors, user),
      ),
    );
  }

  Widget _buildContent(dynamic colors, UserModel? user) {
    final alamatKtp = _formatFullAddress(
      address: user?.employeeAddress,
      subdistrict: user?.subdistrictName,
      city: user?.cityName,
      province: user?.provinceName,
      postalCode: user?.postalCode,
    );

    final alamatDomisili =
        user?.domicileAddress != null && user!.domicileAddress!.isNotEmpty
        ? _toTitleCase(user.domicileAddress)
        : '-';

    return Column(
      children: [
        _buildAddressCard(
          colors,
          title: 'Alamat Kartu Identitas',
          address: alamatKtp,
        ),
        SizedBox(height: 16.h),
        _buildAddressCard(
          colors,
          title: 'Alamat Domisili',
          address: alamatDomisili,
        ),
      ],
    );
  }

  Widget _buildAddressCard(
    dynamic colors, {
    required String title,
    required String address,
  }) {
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
        children: [
          Text(title, style: AppTextStyles.bodySemiBold(colors.textPrimary)),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: colors.textSecondary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  address,
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
