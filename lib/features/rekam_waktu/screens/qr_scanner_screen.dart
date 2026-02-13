import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _hasScanned = true);
    Navigator.pop(context, barcode.rawValue);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Overlay dengan hole di tengah
          _buildScanOverlay(),

          // Top bar
          _buildTopBar(colors),

          // Bottom instruction
          _buildBottomInstruction(colors),
        ],
      ),
    );
  }

  Widget _buildTopBar(ThemeColors colors) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  'Scan QR Code',
                  style: AppTextStyles.h4(Colors.white),
                ),
              ),
              // Torch toggle
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, state, child) {
                  final torchOn = state.torchState == TorchState.on;
                  return IconButton(
                    onPressed: () => _controller.toggleTorch(),
                    icon: Icon(
                      torchOn ? Icons.flash_on : Icons.flash_off,
                      color: torchOn ? Colors.yellow : Colors.white,
                      size: 24.sp,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = 250.w;
        final left = (constraints.maxWidth - scanAreaSize) / 2;
        final top = (constraints.maxHeight - scanAreaSize) / 2 - 40.h;

        return Stack(
          children: [
            // Dark overlay with transparent hole
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.6),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.red, // Any color, will be cut out
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Corner brackets
            Positioned(
              left: left,
              top: top,
              child: _buildCornerBrackets(scanAreaSize),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCornerBrackets(double size) {
    const color = Colors.white;
    final bracketLength = 30.w;
    final bracketWidth = 3.w;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Top-left
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: bracketLength,
              height: bracketWidth,
              color: color,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: bracketWidth,
              height: bracketLength,
              color: color,
            ),
          ),
          // Top-right
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: bracketLength,
              height: bracketWidth,
              color: color,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: bracketWidth,
              height: bracketLength,
              color: color,
            ),
          ),
          // Bottom-left
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: bracketLength,
              height: bracketWidth,
              color: color,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: bracketWidth,
              height: bracketLength,
              color: color,
            ),
          ),
          // Bottom-right
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: bracketLength,
              height: bracketWidth,
              color: color,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: bracketWidth,
              height: bracketLength,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInstruction(ThemeColors colors) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner, color: Colors.white, size: 32.sp),
              SizedBox(height: 12.h),
              Text(
                'Arahkan kamera ke QR Code karyawan',
                style: AppTextStyles.body(Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                'QR Code akan terdeteksi secara otomatis',
                style: AppTextStyles.caption(Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
