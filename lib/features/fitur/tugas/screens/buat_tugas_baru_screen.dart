import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'package:hrd_app/features/fitur/kehadiran/widgets/multi_select_employee_bottom_sheet.dart';
import 'package:hrd_app/features/fitur/lembur/widgets/file_picker_bottom_sheet.dart';

class BuatTugasBaruScreen extends StatefulWidget {
  const BuatTugasBaruScreen({super.key});

  @override
  State<BuatTugasBaruScreen> createState() => _BuatTugasBaruScreenState();
}

class _BuatTugasBaruScreenState extends State<BuatTugasBaruScreen> {
  List<MemberData> _selectedEmployees = [];
  String? _tipeTugas;
  String? _prioritas;

  DateTime? _mulaiDate;
  TimeOfDay? _mulaiTime;

  DateTime? _berakhirDate;
  TimeOfDay? _berakhirTime;

  File? _attachmentFile;
  String? _attachmentFileName;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _tugasController = TextEditingController();
  late final quill.QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();

  final List<String> _tipeTugasOptions = [
    'Pilih Jenis Tugas',
    'Pribadi',
    'Tim',
    'Proyek',
  ];
  final List<String> _prioritasOptions = [
    'Pilih Prioritas',
    'Tinggi',
    'Sedang',
    'Rendah',
  ];

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
  }

  @override
  void dispose() {
    _quillController.dispose();
    _editorFocusNode.dispose();
    _tugasController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isMulai) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        setState(() {
          if (isMulai) {
            _mulaiDate = pickedDate;
            _mulaiTime = pickedTime;
          } else {
            _berakhirDate = pickedDate;
            _berakhirTime = pickedTime;
          }
        });
      }
    }
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return 'Pilih Waktu';
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final dateStr = DateFormat('dd MMM yyyy').format(date);
    return '$timeStr | $dateStr';
  }

  void _showDropdown(
    ThemeColors colors,
    String title,
    List<String> options,
    ValueChanged<String> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyles.h4(colors.textPrimary)),
              SizedBox(height: 12.h),
              Divider(height: 1, color: colors.divider),
              ...options.map(
                (item) => InkWell(
                  onTap: () {
                    onSelected(item);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: colors.divider)),
                    ),
                    child: Text(
                      item,
                      style: AppTextStyles.body(colors.textPrimary),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFile() async {
    final type = await FilePickerBottomSheet.show(context);

    if (type == null || !mounted) return;

    try {
      switch (type) {
        case FilePickerType.camera:
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.camera,
            imageQuality: 80,
          );
          if (image != null) {
            await _setAttachment(File(image.path), image.name);
          }
          break;
        case FilePickerType.gallery:
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
          );
          if (image != null) {
            await _setAttachment(File(image.path), image.name);
          }
          break;
        case FilePickerType.file:
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: [
              'txt',
              'doc',
              'docx',
              'jpg',
              'png',
              'gif',
              'xls',
              'xlsx',
              'pdf',
            ],
          );
          if (result != null && result.files.isNotEmpty) {
            final file = result.files.first;
            if (file.path != null) {
              await _setAttachment(File(file.path!), file.name);
            }
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih file: ${e.toString()}')),
        );
      }
    }
  }

  // Max attachment size: 1MB
  static const int _maxFileSizeBytes = 1 * 1024 * 1024;

  Future<void> _setAttachment(File file, String fileName) async {
    final fileSize = await file.length();
    if (fileSize > _maxFileSizeBytes) {
      if (mounted) {
        final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ukuran file "$fileName" ($fileSizeMB MB) melebihi batas maksimal 1 MB',
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _attachmentFile = file;
      _attachmentFileName = fileName;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File "$fileName" berhasil dipilih')),
      );
    }
  }

  void _removeAttachment() {
    setState(() {
      _attachmentFile = null;
      _attachmentFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    bool isFormComplete =
        _selectedEmployees.isNotEmpty &&
        _tugasController.text.isNotEmpty &&
        _tipeTugas != null &&
        _tipeTugas != 'Pilih Jenis Tugas' &&
        _prioritas != null &&
        _prioritas != 'Pilih Prioritas' &&
        _mulaiDate != null &&
        _berakhirDate != null;

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
          'Buat Tugas Baru',
          style: AppTextStyles.h3(colors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(colors, 'Ditugaskan Ke *'),
            SizedBox(height: 4.h),
            GestureDetector(
              onTap: () async {
                final result = await MultiSelectEmployeeBottomSheet.show(
                  context,
                  initialSelectedItems: _selectedEmployees,
                );
                if (result != null) setState(() => _selectedEmployees = result);
              },
              child: _buildTextFieldContainer(
                colors,
                hint: _selectedEmployees.isEmpty
                    ? 'Pilih Karyawan'
                    : '${_selectedEmployees.length} Terpilih',
                suffixIcon: Icons.people_outline,
              ),
            ),
            SizedBox(height: 12.h),

            _buildLabel(colors, 'Tugas'),
            SizedBox(height: 4.h),
            _buildTextFieldInput(
              colors,
              hint: 'Nama tugas',
              controller: _tugasController,
            ),
            SizedBox(height: 12.h),

            _buildLabel(colors, 'Tipe Tugas'),
            SizedBox(height: 4.h),
            GestureDetector(
              onTap: () {
                _showDropdown(
                  colors,
                  'Pilih Jenis Tugas',
                  _tipeTugasOptions,
                  (val) => setState(() => _tipeTugas = val),
                );
              },
              child: _buildTextFieldContainer(
                colors,
                hint: _tipeTugas ?? 'Pilih Jenis Tugas',
                suffixIcon: Icons.keyboard_arrow_down,
              ),
            ),
            SizedBox(height: 12.h),

            _buildLabel(colors, 'Prioritas'),
            SizedBox(height: 4.h),
            GestureDetector(
              onTap: () {
                _showDropdown(
                  colors,
                  'Pilih Prioritas',
                  _prioritasOptions,
                  (val) => setState(() => _prioritas = val),
                );
              },
              child: _buildTextFieldContainer(
                colors,
                hint: _prioritas ?? 'Pilih Prioritas',
                suffixIcon: Icons.keyboard_arrow_down,
              ),
            ),
            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(colors, 'Mulai'),
                      SizedBox(height: 4.h),
                      GestureDetector(
                        onTap: () => _selectDateTime(context, true),
                        child: _buildTextFieldContainer(
                          colors,
                          hint: _formatDateTime(_mulaiDate, _mulaiTime),
                          suffixIcon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(colors, 'Berakhir'),
                      SizedBox(height: 4.h),
                      GestureDetector(
                        onTap: () => _selectDateTime(context, false),
                        child: _buildTextFieldContainer(
                          colors,
                          hint: _formatDateTime(_berakhirDate, _berakhirTime),
                          suffixIcon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            _buildLabel(colors, 'Keterangan'),
            SizedBox(height: 4.h),
            _buildRichTextEditor(colors),

            SizedBox(height: 12.h),

            _buildLabel(colors, 'Lampiran'),
            SizedBox(height: 4.h),
            _buildAttachmentSection(colors),

            SizedBox(
              height: 24.h,
            ), // add padding at bottom for smooth scroll above sticky button
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(colors, isFormComplete),
    );
  }

  Widget _buildBottomButton(ThemeColors colors, bool isFormComplete) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: colors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isFormComplete ? () => Navigator.pop(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: colors.primaryBlue.withValues(
                alpha: 0.5,
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            child: Text('Ajukan', style: AppTextStyles.button(Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentSection(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_attachmentFileName != null) ...[
          Container(
            margin: EdgeInsets.only(bottom: 6.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: colors.backgroundDetail,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: colors.divider),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attachment,
                  color: colors.textSecondary,
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    _attachmentFileName!,
                    style: AppTextStyles.body(
                      colors.textPrimary,
                      fontSize: 13.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: _removeAttachment,
                  child: Icon(Icons.close, color: colors.error, size: 16.sp),
                ),
              ],
            ),
          ),
        ],
        if (_attachmentFileName == null)
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: colors.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: colors.primaryBlue, size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'Pilih File',
                    style: AppTextStyles.body(
                      colors.primaryBlue,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(ThemeColors colors, String text) {
    return Text(text, style: AppTextStyles.smallMedium(colors.textSecondary));
  }

  Widget _buildTextFieldContainer(
    ThemeColors colors, {
    required String hint,
    required IconData suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              hint,
              style: AppTextStyles.small(
                hint.contains('Pilih') ||
                        hint.contains('Terpilih') ||
                        hint.contains('Nama') ||
                        hint.contains('Waktu')
                    ? colors.textSecondary
                    : colors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(suffixIcon, color: colors.textSecondary, size: 18.sp),
        ],
      ),
    );
  }

  Widget _buildTextFieldInput(
    ThemeColors colors, {
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.small(colors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
        ),
        style: AppTextStyles.small(colors.textPrimary),
      ),
    );
  }

  // Replaced with _buildBottomButton above

  Widget _buildRichTextEditor(ThemeColors colors) {
    const quillIconTheme = quill.QuillIconTheme(
      iconButtonUnselectedData: quill.IconButtonData(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: 26, minHeight: 26),
      ),
      iconButtonSelectedData: quill.IconButtonData(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: 26, minHeight: 26),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar Custom 3 Baris
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 4.w,
                  runSpacing: 4.h,
                  children: [
                    _buildToolbarGroup(colors, [
                      quill.QuillToolbarHistoryButton(
                        controller: _quillController,
                        isUndo: true,
                        options: const quill.QuillToolbarHistoryButtonOptions(
                          iconSize: 14,
                          iconTheme: quillIconTheme,
                        ),
                      ),
                      quill.QuillToolbarHistoryButton(
                        controller: _quillController,
                        isUndo: false,
                        options: const quill.QuillToolbarHistoryButtonOptions(
                          iconSize: 14,
                          iconTheme: quillIconTheme,
                        ),
                      ),
                    ]),
                    _buildToolbarGroup(colors, [
                      quill.QuillToolbarFontFamilyButton(
                        controller: _quillController,
                        options:
                            const quill.QuillToolbarFontFamilyButtonOptions(
                              iconSize: 14,
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              defaultDisplayText: 'Font',
                            ),
                      ),
                      quill.QuillToolbarFontSizeButton(
                        controller: _quillController,
                        options: const quill.QuillToolbarFontSizeButtonOptions(
                          iconSize: 14,
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          defaultDisplayText: 'Ukuran',
                          items: {
                            '10px': '10',
                            '12px': '12',
                            '14px': '14',
                            '16px': '16',
                            '18px': '18',
                            '24px': '24',
                            '32px': '32',
                          },
                        ),
                      ),
                    ]),
                    _buildToolbarGroup(colors, [
                      quill.QuillToolbarToggleStyleButton(
                        controller: _quillController,
                        attribute: quill.Attribute.bold,
                        options:
                            const quill.QuillToolbarToggleStyleButtonOptions(
                              iconSize: 14,
                              iconTheme: quillIconTheme,
                            ),
                      ),
                      quill.QuillToolbarToggleStyleButton(
                        controller: _quillController,
                        attribute: quill.Attribute.underline,
                        options:
                            const quill.QuillToolbarToggleStyleButtonOptions(
                              iconSize: 14,
                              iconTheme: quillIconTheme,
                            ),
                      ),
                      quill.QuillToolbarToggleStyleButton(
                        controller: _quillController,
                        attribute: quill.Attribute.italic,
                        options:
                            const quill.QuillToolbarToggleStyleButtonOptions(
                              iconSize: 14,
                              iconTheme: quillIconTheme,
                            ),
                      ),
                      quill.QuillToolbarToggleStyleButton(
                        controller: _quillController,
                        attribute: quill.Attribute.strikeThrough,
                        options:
                            const quill.QuillToolbarToggleStyleButtonOptions(
                              iconSize: 14,
                              iconTheme: quillIconTheme,
                            ),
                      ),
                    ]),
                    _buildToolbarGroup(colors, [
                      quill.QuillToolbarColorButton(
                        controller: _quillController,
                        isBackground: false,
                        options: const quill.QuillToolbarColorButtonOptions(
                          iconSize: 14,
                          iconTheme: quillIconTheme,
                        ),
                      ),
                      quill.QuillToolbarColorButton(
                        controller: _quillController,
                        isBackground: true,
                        options: const quill.QuillToolbarColorButtonOptions(
                          iconSize: 14,
                          iconTheme: quillIconTheme,
                        ),
                      ),
                    ]),
                    _buildToolbarGroup(colors, [
                      quill.QuillToolbarToggleStyleButton(
                        controller: _quillController,
                        attribute: quill.Attribute.ol,
                        options:
                            const quill.QuillToolbarToggleStyleButtonOptions(
                              iconSize: 14,
                              iconTheme: quillIconTheme,
                            ),
                      ),
                      quill.QuillToolbarToggleStyleButton(
                        controller: _quillController,
                        attribute: quill.Attribute.ul,
                        options:
                            const quill.QuillToolbarToggleStyleButtonOptions(
                              iconSize: 14,
                              iconTheme: quillIconTheme,
                            ),
                      ),
                    ]),
                    _buildToolbarGroup(colors, [
                      quill.QuillToolbarLinkStyleButton(
                        controller: _quillController,
                      ),
                      quill.QuillToolbarClearFormatButton(
                        controller: _quillController,
                        options:
                            const quill.QuillToolbarClearFormatButtonOptions(
                              iconSize: 14,
                              iconTheme: quillIconTheme,
                            ),
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.divider),
          // Text Area (Mulai dari Atas)
          Container(
            height: 150.h,
            color: colors.background,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            alignment: Alignment.topLeft,
            child: quill.QuillEditor.basic(
              controller: _quillController,
              focusNode: _editorFocusNode,
              config: const quill.QuillEditorConfig(
                placeholder: 'Ketik di sini',
                padding: EdgeInsets.zero,
                expands: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarGroup(ThemeColors colors, List<Widget> children) {
    List<Widget> separated = [];
    for (int i = 0; i < children.length; i++) {
      separated.add(children[i]);
      if (i != children.length - 1) {
        separated.add(Container(width: 1, height: 18.h, color: colors.divider));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: separated,
      ),
    );
  }
}
