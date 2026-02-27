import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

import 'package:hrd_app/data/services/attendance_service.dart';

class AttendanceLocationBottomSheet extends StatefulWidget {
  final String? employeeId;
  final DateTime? date;
  final String type; // 'CHECK_IN' or 'CHECK_OUT'

  const AttendanceLocationBottomSheet({
    super.key,
    this.employeeId,
    this.date,
    required this.type,
  });

  static void show({
    required BuildContext context,
    String? employeeId,
    DateTime? date,
    required String type,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttendanceLocationBottomSheet(
        employeeId: employeeId,
        date: date,
        type: type,
      ),
    );
  }

  @override
  State<AttendanceLocationBottomSheet> createState() =>
      _AttendanceLocationBottomSheetState();
}

class _AttendanceLocationBottomSheetState
    extends State<AttendanceLocationBottomSheet> {
  bool _isLoading = true;
  String? _error;

  // Attendance data
  String? _time;
  String? _location;
  LatLng? _attendanceLatLng;

  // Location areas
  List<Map<String, dynamic>> _areas = [];

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final response = await AttendanceService().getLocation(
        employeeId: widget.employeeId,
        date: widget.date,
        type: widget.type,
      );

      final records = response['original']?['records'] ?? response['records'];

      if (records == null) {
        if (mounted) {
          setState(() {
            _error = 'Data tidak ditemukan';
            _isLoading = false;
          });
        }
        return;
      }

      final attendance = records['attendance'] as Map<String, dynamic>?;
      final locationAreas = records['location_area'] as List? ?? [];

      // Parse attendance location coordinates
      LatLng? latLng;
      final locStr = attendance?['attendance_location'] as String?;
      if (locStr != null && locStr.contains(',')) {
        final parts = locStr.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null) {
            latLng = LatLng(lat, lng);
          }
        }
      }

      if (mounted) {
        setState(() {
          _time = attendance?['time'] as String?;
          _location = locStr;
          _attendanceLatLng = latLng;
          _areas = locationAreas.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching location: $e');
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data lokasi';
          _isLoading = false;
        });
      }
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Attendance position marker
    if (_attendanceLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('attendance'),
          position: _attendanceLatLng!,
          infoWindow: InfoWindow(
            title: widget.type == 'CHECK_IN' ? 'Lokasi Masuk' : 'Lokasi Keluar',
            snippet: _time ?? '',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            widget.type == 'CHECK_IN'
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    // Area markers
    for (int i = 0; i < _areas.length; i++) {
      final area = _areas[i];
      final lat = double.tryParse(area['lat_area']?.toString() ?? '');
      final lng = double.tryParse(area['long_area']?.toString() ?? '');
      if (lat != null && lng != null) {
        markers.add(
          Marker(
            markerId: MarkerId('area_$i'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: area['area_name'] ?? 'Area',
              snippet: 'Radius: ${area['max_radius_area'] ?? '-'} km',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      }
    }

    return markers;
  }

  Set<Circle> _buildCircles() {
    final circles = <Circle>{};

    for (int i = 0; i < _areas.length; i++) {
      final area = _areas[i];
      final lat = double.tryParse(area['lat_area']?.toString() ?? '');
      final lng = double.tryParse(area['long_area']?.toString() ?? '');
      final radiusKm = double.tryParse(
        area['max_radius_area']?.toString() ?? '',
      );

      if (lat != null && lng != null && radiusKm != null) {
        circles.add(
          Circle(
            circleId: CircleId('area_circle_$i'),
            center: LatLng(lat, lng),
            radius: radiusKm * 1000, // km to meters
            fillColor: Colors.green.withValues(alpha: 0.15),
            strokeColor: Colors.green.withValues(alpha: 0.6),
            strokeWidth: 2,
          ),
        );
      }
    }

    return circles;
  }

  void _fitMapBounds() {
    if (_mapController == null) return;

    final points = <LatLng>[];
    if (_attendanceLatLng != null) points.add(_attendanceLatLng!);
    for (final area in _areas) {
      final lat = double.tryParse(area['lat_area']?.toString() ?? '');
      final lng = double.tryParse(area['long_area']?.toString() ?? '');
      if (lat != null && lng != null) points.add(LatLng(lat, lng));
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 16),
      );
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Peta',
                  style: AppTextStyles.h4(colors.textPrimary),
                ),
              ),
              SizedBox(height: 8.h),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? _buildError(colors)
                    : _buildContent(colors, scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: colors.divider),
          SizedBox(height: 12.h),
          Text(_error!, style: AppTextStyles.body(colors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeColors colors, ScrollController sc) {
    return ListView(
      controller: sc,
      padding: EdgeInsets.zero,
      children: [
        // Google Map
        Container(
          height: 400.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colors.divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _attendanceLatLng ?? const LatLng(-6.2, 106.8),
              zoom: 15,
            ),
            markers: _buildMarkers(),
            circles: _buildCircles(),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              Future.delayed(const Duration(milliseconds: 500), () {
                _fitMapBounds();
              });
            },
          ),
        ),
        SizedBox(height: 12.h),

        // Coordinate info
        if (_location != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Icon(Icons.my_location, color: colors.primaryBlue, size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _location!,
                    style: AppTextStyles.caption(colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

        // Time
        if (_time != null)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 0),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: colors.textSecondary,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  _time!,
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
              ],
            ),
          ),

        SizedBox(height: 20.h),
      ],
    );
  }
}
