import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeBottomSheet extends StatefulWidget {
  final String username;
  final String name;
  final String role;

  const QrCodeBottomSheet({
    super.key,
    required this.username,
    required this.name,
    required this.role,
  });

  @override
  State<QrCodeBottomSheet> createState() => _QrCodeBottomSheetState();
}

class _QrCodeBottomSheetState extends State<QrCodeBottomSheet> {
  bool _isQrCode = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.appBar,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colors.textSecondary.withAlpha(80),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),

          // Title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _isQrCode ? 'Kode QR' : 'Barcode',
              style: AppTextStyles.h3(colors.textPrimary),
            ),
          ),
          SizedBox(height: 32.h),

          // QR Code or Barcode
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isQrCode ? _buildQrCode(colors) : _buildBarcode(colors),
          ),
          SizedBox(height: 24.h),

          // User info
          Text(
            widget.name.toUpperCase(),
            style: AppTextStyles.bodySemiBold(colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            widget.role,
            style: AppTextStyles.captionMedium(colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            widget.username,
            style: AppTextStyles.caption(colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),

          // Toggle button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _isQrCode = !_isQrCode),
              child: Text(
                'Ganti',
                style: AppTextStyles.bodySemiBold(colors.textSecondary),
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildQrCode(ThemeColors colors) {
    return SizedBox(
      key: const ValueKey('qr'),
      width: 200.w,
      height: 200.w,
      child: QrImageView(
        data: widget.username,
        version: QrVersions.auto,
        size: 200.w,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildBarcode(ThemeColors colors) {
    return Container(
      key: const ValueKey('barcode'),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: BarcodeWidget(
        barcode: Barcode.code128(),
        data: widget.username,
        width: 220.w,
        height: 80.h,
        drawText: true,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
