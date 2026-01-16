import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:camera/camera.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/utils/snackbar_utils.dart';
import 'package:hrd_app/features/rekam_waktu/screens/rekam_waktu_confirm_screen.dart';

class RekamWaktuCameraScreen extends StatefulWidget {
  const RekamWaktuCameraScreen({super.key});

  @override
  State<RekamWaktuCameraScreen> createState() => _RekamWaktuCameraScreenState();
}

class _RekamWaktuCameraScreenState extends State<RekamWaktuCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  bool _isCapturing = false;
  bool _isFlashOn = false;
  int _selectedCameraIndex = 1;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          context.showErrorSnackbar('Tidak ada kamera tersedia');
          Navigator.pop(context);
        }
        return;
      }

      _selectedCameraIndex = _cameras!.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;

      await _setupCamera(_selectedCameraIndex);
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar('Gagal mengakses kamera');
        Navigator.pop(context);
      }
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
          _selectedCameraIndex = cameraIndex;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar('Gagal mengaktifkan kamera');
      }
    }
  }

  void _toggleCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final newIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    setState(() => _isCameraReady = false);
    await _setupCamera(newIndex);
  }

  void _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_cameras![_selectedCameraIndex].lensDirection ==
        CameraLensDirection.front) {
      context.showInfoSnackbar('Flash tidak tersedia di kamera depan');
      return;
    }

    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (_) {}
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      }

      final XFile photo = await _controller!.takePicture();

      final controllerToDispose = _controller;
      setState(() {
        _isCameraReady = false;
        _controller = null;
      });
      await controllerToDispose?.dispose();

      if (mounted) {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RekamWaktuConfirmScreen(photo: File(photo.path)),
          ),
        );

        if (result == true && mounted) {
          Navigator.pop(context);
        } else if (mounted) {
          setState(() => _isCapturing = false);
          await _initCamera();
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar('Gagal mengambil foto');
        setState(() => _isCapturing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_isCameraReady && _controller != null)
              Positioned.fill(child: _buildCameraPreview())
            else
              _buildLoadingState(colors),

            if (_isCameraReady)
              Positioned.fill(
                child: Image.asset(
                  'assets/images/silhouette_face.png',
                  fit: BoxFit.contain,
                ),
              ),

            _buildTopBar(colors),

            _buildBottomBar(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final size = MediaQuery.of(context).size;
    final cameraRatio = _controller!.value.aspectRatio;

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: size.width,
            height: size.width * cameraRatio,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primaryBlue),
          SizedBox(height: 16.h),
          Text('Memuat kamera...', style: AppTextStyles.body(Colors.white)),
        ],
      ),
    );
  }

  Widget _buildTopBar(ThemeColors colors) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          ),
        ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rekam Waktu', style: AppTextStyles.h4(Colors.white)),
                  Text(
                    'Posisikan wajah dalam bingkai',
                    style: AppTextStyles.caption(Colors.white70),
                  ),
                ],
              ),
            ),
            if (_cameras != null && _cameras!.length > 1)
              IconButton(
                onPressed: _isCameraReady ? _toggleCamera : null,
                icon: Icon(
                  Icons.cameraswitch_rounded,
                  color: Colors.white,
                  size: 24.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(ThemeColors colors) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _isCameraReady ? _toggleFlash : null,
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: _isFlashOn ? Colors.yellow : Colors.white,
                size: 28.sp,
              ),
            ),

            GestureDetector(
              onTap: (_isCapturing || !_isCameraReady) ? null : _capturePhoto,
              child: Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Container(
                  margin: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCapturing ? Colors.grey : Colors.white,
                  ),
                  child: _isCapturing
                      ? Center(
                          child: SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.primaryBlue,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.camera_alt,
                          color: Colors.black87,
                          size: 28.sp,
                        ),
                ),
              ),
            ),

            SizedBox(width: 48.w),
          ],
        ),
      ),
    );
  }
}
