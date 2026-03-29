import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';

class DynamicFieldAktivitasModel {
  String label;
  String type;
  
  DynamicFieldAktivitasModel({this.label = '', this.type = 'Pilih Jenis Masukan'});
}

class BuatJenisAktivitasScreen extends StatefulWidget {
  const BuatJenisAktivitasScreen({super.key});

  @override
  State<BuatJenisAktivitasScreen> createState() => _BuatJenisAktivitasScreenState();
}

class _BuatJenisAktivitasScreenState extends State<BuatJenisAktivitasScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<DynamicFieldAktivitasModel> _dynamicFields = [];

  void _addField() {
    setState(() {
      _dynamicFields.add(DynamicFieldAktivitasModel());
    });
  }

  void _removeField(int index) {
    setState(() {
      _dynamicFields.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildDynamicFieldItem(ThemeColors colors, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.h, right: 12.w),
            child: Icon(Icons.drag_indicator, color: colors.textSecondary, size: 20.sp),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Atribut Label', style: AppTextStyles.smallMedium(colors.textSecondary)),
                SizedBox(height: 8.h),
                TextField(
                  onChanged: (val) => _dynamicFields[index].label = val,
                  style: AppTextStyles.body(colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Masukkan Label',
                    hintStyle: AppTextStyles.body(colors.textSecondary),
                    filled: true,
                    fillColor: colors.background,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: colors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: colors.primaryBlue),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text('Tipe Masukkan', style: AppTextStyles.smallMedium(colors.textSecondary)),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.divider),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dynamicFields[index].type,
                        style: AppTextStyles.body(colors.textSecondary).copyWith(fontSize: 14.sp),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: colors.textSecondary, size: 20.sp),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => _removeField(index),
                    child: Icon(Icons.delete_outline, color: colors.textSecondary, size: 24.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
          'Buat Jenis Aktivitas',
          style: AppTextStyles.h4(colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nama Tipe Aktivitas',
                style: AppTextStyles.smallMedium(colors.textSecondary),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _nameController,
                style: AppTextStyles.body(colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Masukkan Nama Jenis Aktivitas',
                  hintStyle: AppTextStyles.body(colors.textSecondary),
                  filled: true,
                  fillColor: colors.background,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: colors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: colors.primaryBlue),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Divider(color: colors.divider),
              SizedBox(height: 16.h),
              Text(
                'Bidang Dinamis',
                style: AppTextStyles.bodyLarge(colors.textPrimary).copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16.h),
              ...List.generate(
                _dynamicFields.length,
                (index) => _buildDynamicFieldItem(colors, index),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addField,
                  icon: Icon(Icons.add, color: colors.primaryBlue, size: 18.sp),
                  label: Text(
                    'Tambahkan Bidang Dinamis',
                    style: AppTextStyles.button(colors.primaryBlue),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.primaryBlue),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: colors.background,
            border: Border(top: BorderSide(color: colors.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.error),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Batalkan',
                    style: AppTextStyles.button(colors.error),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Simpan
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryBlue,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Simpan',
                    style: AppTextStyles.button(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
