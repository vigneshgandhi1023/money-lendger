import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/customer.dart';
import '../../models/loan.dart';
import '../../models/payment.dart';
import '../utils/currency_formatter.dart';

/// PDF export service for generating professional reports.
///
/// Generates beautifully formatted PDF documents for:
/// - Daily/Weekly/Monthly collection reports
/// - Outstanding loans summary
/// - Customer statements
class ExportService {
  ExportService._();

  // ─── Collection Report ─────────────────────────────────

  /// Generate a collection report for a date range.
  static Future<Uint8List> generateCollectionReport({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required List<Payment> payments,
    required double totalCollected,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('d MMM yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(title, startDate, endDate),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F1F5F9'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Total Collected',
                        style: pw.TextStyle(
                            fontSize: 12, color: PdfColor.fromHex('#475569'))),
                    pw.SizedBox(height: 4),
                    pw.Text(CurrencyFormatter.format(totalCollected),
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Transactions',
                        style: pw.TextStyle(
                            fontSize: 12, color: PdfColor.fromHex('#475569'))),
                    pw.SizedBox(height: 4),
                    pw.Text('${payments.length}',
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // Payments table
          if (payments.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#3F37C9'),
                borderRadius: const pw.BorderRadius.vertical(
                    top: pw.Radius.circular(6)),
              ),
              headerPadding:
                  const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              cellPadding:
                  const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerLeft,
              },
              headers: ['Date', 'Customer', 'Amount', 'Notes'],
              data: payments.map((p) {
                return [
                  dateFormat.format(p.paymentDate),
                  p.customerId,
                  CurrencyFormatter.format(p.amount),
                  p.notes ?? '-',
                ];
              }).toList(),
            )
          else
            pw.Center(
              child: pw.Text('No transactions in this period',
                  style: pw.TextStyle(
                      fontSize: 14, color: PdfColor.fromHex('#94A3B8'))),
            ),
        ],
      ),
    );

    return pdf.save();
  }

  // ─── Outstanding Loans Report ──────────────────────────

  /// Generate an outstanding loans summary report.
  static Future<Uint8List> generateOutstandingReport({
    required List<Loan> loans,
    required Map<String, Customer> customerMap,
    required double totalOutstanding,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('d MMM yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildSimpleHeader('Outstanding Loans Report'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#FEE2E2'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Total Outstanding',
                        style: pw.TextStyle(
                            fontSize: 12, color: PdfColor.fromHex('#7F1D1D'))),
                    pw.SizedBox(height: 4),
                    pw.Text(CurrencyFormatter.format(totalOutstanding),
                        style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#EF4444'))),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Active Loans',
                        style: pw.TextStyle(
                            fontSize: 12, color: PdfColor.fromHex('#7F1D1D'))),
                    pw.SizedBox(height: 4),
                    pw.Text('${loans.length}',
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          if (loans.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#EF4444'),
                borderRadius: const pw.BorderRadius.vertical(
                    top: pw.Radius.circular(6)),
              ),
              headerPadding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              cellPadding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headers: [
                'Customer',
                'Loan Amount',
                'Outstanding',
                'Due Date',
                'Status'
              ],
              data: loans.map((l) {
                final customer = customerMap[l.customerId];
                return [
                  customer?.fullName ?? 'Unknown',
                  CurrencyFormatter.format(l.loanAmount),
                  CurrencyFormatter.format(l.remainingBalance),
                  dateFormat.format(l.dueDate),
                  l.isOverdue ? 'OVERDUE' : 'Active',
                ];
              }).toList(),
            ),
        ],
      ),
    );

    return pdf.save();
  }

  // ─── Share/Print ───────────────────────────────────────

  /// Share or print a PDF document.
  static Future<void> sharePdf(Uint8List pdfData, String fileName) async {
    await Printing.sharePdf(bytes: pdfData, filename: fileName);
  }

  /// Print a PDF document.
  static Future<void> printPdf(Uint8List pdfData) async {
    await Printing.layoutPdf(onLayout: (_) async => pdfData);
  }

  // ─── Helpers ───────────────────────────────────────────

  static pw.Widget _buildHeader(
      String title, DateTime startDate, DateTime endDate) {
    final dateFormat = DateFormat('d MMM yyyy');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Loan Ledger',
                style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#3F37C9'))),
            pw.Text(
                '${dateFormat.format(startDate)} — ${dateFormat.format(endDate)}',
                style: pw.TextStyle(
                    fontSize: 11, color: PdfColor.fromHex('#475569'))),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(title,
            style: pw.TextStyle(
                fontSize: 16, color: PdfColor.fromHex('#0F172A'))),
        pw.SizedBox(height: 12),
        pw.Divider(color: PdfColor.fromHex('#E2E8F0')),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _buildSimpleHeader(String title) {
    final dateFormat = DateFormat('d MMM yyyy');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Loan Ledger',
                style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#3F37C9'))),
            pw.Text('Generated: ${dateFormat.format(DateTime.now())}',
                style: pw.TextStyle(
                    fontSize: 11, color: PdfColor.fromHex('#475569'))),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(title,
            style: pw.TextStyle(
                fontSize: 16, color: PdfColor.fromHex('#0F172A'))),
        pw.SizedBox(height: 12),
        pw.Divider(color: PdfColor.fromHex('#E2E8F0')),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 12),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style:
            pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#94A3B8')),
      ),
    );
  }
}
