import 'package:flutter/services.dart';
import 'package:hrd_app/data/models/payroll_detail_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Service untuk generate PDF slip gaji - A4 Landscape
class PayslipPdfService {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  static Future<void> _loadFonts() async {
    if (_regularFont == null || _boldFont == null) {
      _regularFont = await PdfGoogleFonts.robotoRegular();
      _boldFont = await PdfGoogleFonts.robotoBold();
    }
  }

  static Future<Uint8List> generatePdf(PayrollDetailModel payrollDetail) async {
    await _loadFonts();

    final pdf = pw.Document();
    final logoData = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    final data = payrollDetail.data;
    if (data == null) throw Exception('Payroll data not available');

    final grandTotalDeductions =
        (data.subTotalDeductions ?? 0) + (data.totalTax ?? 0);
    final theme = pw.ThemeData.withFont(base: _regularFont, bold: _boldFont);

    final monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final periodMonth = payrollDetail.periodMonth ?? 0;
    final periodYear = payrollDetail.periodYear ?? 0;
    final periodText = periodMonth >= 1 && periodMonth <= 12
        ? '${monthNames[periodMonth]} $periodYear'
        : '-';
    final accessorName = payrollDetail.accessorName ?? '-';

    // Prepare earnings data rows (Salary + allowances from API)
    final List<_RowData> earningsDataRows = [
      _RowData('Salary', data.basicSalary),
      ...data.allowances.map(
        (a) => _RowData(a.allowanceName ?? '-', a.allowanceAmount),
      ),
    ];

    // Prepare deductions data rows - ONLY from API, no hardcoded items
    final List<_RowData> deductionsDataRows = [
      ...data.deductions.map(
        (d) => _RowData(d.deductionName ?? '-', d.deductionAmount ?? 0),
      ),
    ];

    // Calculate empty rows needed to balance tables
    final earningsCount = earningsDataRows.length;
    final deductionsCount = deductionsDataRows.length;
    final maxDataRows = earningsCount > deductionsCount
        ? earningsCount
        : deductionsCount;
    final earningsEmptyRows = maxDataRows - earningsCount;
    final deductionsEmptyRows = maxDataRows - deductionsCount;

    // Build UNIFIED table with Earnings (LEFT) and Deductions (RIGHT) - ROW BY ROW
    pw.Widget buildUnifiedTable() {
      // Prepare data lists
      final leftData = <_RowData>[
        ...earningsDataRows,
        for (int i = 0; i < earningsEmptyRows; i++) _RowData('', null),
      ];
      final rightData = <_RowData>[
        ...deductionsDataRows,
        for (int i = 0; i < deductionsEmptyRows; i++) _RowData('', null),
      ];

      // Summary rows - matched positions
      final leftSummary = <_RowData>[
        _RowData('Subtotal Earnings', data.totalEarning),
        _RowData('Tax Allowance', data.totalTaxAllowance),
        _RowData('Tax Borne By Company', data.totalTaxBorneByCompany),
        _RowData(
          'Tax Penalty Borne By Company',
          data.totalTaxPenaltyBorneByCompany,
        ),
        _RowData('Total Earnings', data.grossSalary),
        _RowData('', null), // Empty row to pair with Net Pay
      ];
      final rightSummary = <_RowData>[
        _RowData('Subtotal Deductions', data.subTotalDeductions),
        _RowData('Tax', data.totalTax),
        _RowData('Tax Penalty', data.totalTaxPenalty),
        _RowData('', null), // Empty row to pair with Tax Penalty Borne
        _RowData('Total Deductions', grandTotalDeductions),
        _RowData('Net Pay', data.netSalary),
      ];

      // Simple cell - NO internal borders, just text with format: Label : IDR Amount
      pw.Widget buildCell(String label, num? amount, {bool isBold = false}) {
        final style = pw.TextStyle(
          fontSize: 8,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        );
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: pw.Row(
            children: [
              pw.Expanded(child: pw.Text(label, style: style)),
              if (label.isNotEmpty) ...[
                pw.Text(':  ', style: style),
                pw.Text('IDR', style: style),
                pw.SizedBox(width: 8),
                pw.SizedBox(
                  width: 60,
                  child: pw.Text(
                    _formatNumber(amount ?? 0),
                    style: style,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ],
          ),
        );
      }

      // Build header row
      pw.Widget buildHeaderRow() {
        return pw.Container(
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
          ),
          child: pw.Row(
            children: [
              // Left header
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 5,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'Earning Allowances',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Right header with left border (center divider)
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 5,
                  ),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(left: pw.BorderSide(width: 0.5)),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'Deductions',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Build a paired row (left + right) with optional top border
      pw.Widget buildPairedRow(
        _RowData left,
        _RowData right, {
        bool leftBold = false,
        bool rightBold = false,
        bool hasBorder = false,
      }) {
        return pw.Container(
          decoration: pw.BoxDecoration(
            border: hasBorder
                ? const pw.Border(top: pw.BorderSide(width: 0.5))
                : null,
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left cell
              pw.Expanded(
                child: buildCell(left.label, left.amount, isBold: leftBold),
              ),
              // Right cell with left border (creates center divider effect)
              pw.Expanded(
                child: pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(left: pw.BorderSide(width: 0.5)),
                  ),
                  child: buildCell(
                    right.label,
                    right.amount,
                    isBold: rightBold,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return pw.Container(
        decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
        child: pw.Column(
          children: [
            // Header row
            buildHeaderRow(),
            // Data rows - NO borders between rows
            for (int i = 0; i < leftData.length; i++)
              buildPairedRow(leftData[i], rightData[i]),
            // Summary rows - WITH top border on certain rows
            buildPairedRow(
              leftSummary[0],
              rightSummary[0],
              leftBold: true,
              rightBold: true,
              hasBorder: true,
            ), // Subtotals
            buildPairedRow(
              leftSummary[1],
              rightSummary[1],
            ), // Tax Allowance / Tax
            buildPairedRow(
              leftSummary[2],
              rightSummary[2],
            ), // Tax Borne / Tax Penalty
            buildPairedRow(
              leftSummary[3],
              rightSummary[3],
            ), // Tax Penalty Borne / (empty)
            buildPairedRow(
              leftSummary[4],
              rightSummary[4],
              leftBold: true,
              rightBold: true,
              hasBorder: true,
            ), // Total Earnings / Total Deductions
            buildPairedRow(
              leftSummary[5],
              rightSummary[5],
              rightBold: true,
              hasBorder: true,
            ), // (empty) / Net Pay
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          297 * PdfPageFormat.mm,
          210 * PdfPageFormat.mm,
          marginAll: 15 * PdfPageFormat.mm,
        ),
        theme: theme,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER with logo centered
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Image(logoImage, width: 70, height: 70),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'PAY SLIP $periodText',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // EMPLOYEE INFO - Left side: Name, etc. Right side: Tax Ref No, Tax Status
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT COLUMN
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _infoRow('Name', data.employeeName ?? '-'),
                      _infoRow('Employee No.', data.employeeCode ?? '-'),
                      _infoRow(
                        'Position',
                        data.positionOrganizationName ?? '-',
                      ),
                      _infoRow('Cost Center', data.costCenterName ?? '-'),
                    ],
                  ),
                  // RIGHT COLUMN - Tax info (positioned far right)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _infoRow('Tax Ref No', data.taxRefNo ?? '-'),
                      _infoRow('Tax Status', data.taxStatus ?? '-'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // UNIFIED TABLE - Earnings and Deductions side by side
              buildUnifiedTable(),
              pw.SizedBox(height: 6),

              // NET PAY IN WORDS
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  _numberToWords(data.netSalary?.toInt() ?? 0),
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),

              // BANK INFO
              pw.Text(
                'Transferred to : ${data.employeeBankName ?? "-"} - ${data.bankAccountNumberEmployee ?? "-"} - ${data.bankAccountNameEmployee ?? "-"}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Spacer(),

              // FOOTER
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Printed on: ${DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now())}',
                    style: const pw.TextStyle(
                      fontSize: 7,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'Printed by: $accessorName',
                    style: const pw.TextStyle(
                      fontSize: 7,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          ),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 9)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static String _formatNumber(num? amount) =>
      amount == null ? '0' : NumberFormat('#,###', 'en_US').format(amount);

  static String _numberToWords(int n) {
    if (n == 0) return 'Zero Rupiahs';
    final ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];
    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];
    String convert(int num) {
      if (num < 20) return ones[num];
      if (num < 100) {
        return '${tens[num ~/ 10]}${num % 10 > 0 ? ' ${ones[num % 10]}' : ''}';
      }
      if (num < 1000) {
        return '${ones[num ~/ 100]} Hundred${num % 100 > 0 ? ' ${convert(num % 100)}' : ''}';
      }
      if (num < 1000000) {
        return '${convert(num ~/ 1000)} Thousand${num % 1000 > 0 ? ' ${convert(num % 1000)}' : ''}';
      }
      if (num < 1000000000) {
        return '${convert(num ~/ 1000000)} Million${num % 1000000 > 0 ? ' ${convert(num % 1000000)}' : ''}';
      }
      return '${convert(num ~/ 1000000000)} Billion${num % 1000000000 > 0 ? ' ${convert(num % 1000000000)}' : ''}';
    }

    return '${convert(n)} Rupiahs';
  }
}

class _RowData {
  final String label;
  final num? amount;
  _RowData(this.label, this.amount);
}
