import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/product/domain/entities/product.dart';
import '../../features/sales/domain/entities/sale.dart';

class ExportService {
  // ══════════════════════════════════════════════════════
  //  PRODUCTS — تصدير واستيراد
  // ══════════════════════════════════════════════════════

  /// تصدير المنتجات كـ CSV
  static Future<bool> exportProductsCsv(List<Product> products) async {
    try {
      final rows = [
        ['الاسم', 'الباركود', 'السعر', 'المخزون'],
        ...products.map((p) => [p.name, p.barcode, p.price, p.stock]),
      ];
      final csv = const ListToCsvConverter().convert(rows);

      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/products_export_${_dateTag()}.csv');
      await file.writeAsString('\uFEFF$csv', encoding: utf8); // BOM للعربية

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'قائمة المنتجات',
      );
      return true;
    } catch (e) {
      debugPrint('exportProductsCsv error: $e');
      return false;
    }
  }

  /// استيراد منتجات من CSV
  /// يرجع List<Map> كل map فيها: name, barcode, price, stock
  static Future<List<Map<String, dynamic>>?> importProductsCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return null;

      final path    = result.files.single.path!;
      final content = await File(path).readAsString();
      final rows    = const CsvToListConverter().convert(content);

      if (rows.length < 2) return [];

      // السطر الأول headers — نتجاهله
      final List<Map<String, dynamic>> products = [];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 2) continue;
        products.add({
          'name':    row[0].toString().trim(),
          'barcode': row[1].toString().trim(),
          'price':   double.tryParse(row[2].toString()) ?? 0.0,
          'stock':   int.tryParse(row[3].toString()) ?? 0,
        });
      }
      return products;
    } catch (e) {
      debugPrint('importProductsCsv error: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════
  //  SALES — تصدير تقرير CSV
  // ══════════════════════════════════════════════════════

  static Future<bool> exportSalesCsv(List<Sale> sales) async {
    try {
      final rows = [
        ['رقم الفاتورة', 'التاريخ', 'الإجمالي', 'الخصم', 'الصافي', 'طريقة الدفع', 'المنتجات'],
        ...sales.map((s) => [
          s.id,
          DateFormat('yyyy-MM-dd HH:mm').format(s.date),
          s.total,
          s.discount,
          s.netTotal,
          s.paymentMethod,
          s.items.map((i) => '${i.productName}×${i.quantity}').join(' | '),
        ]),
      ];
      final csv  = const ListToCsvConverter().convert(rows);
      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/sales_report_${_dateTag()}.csv');
      await file.writeAsString('\uFEFF$csv');

      await Share.shareXFiles([XFile(file.path)], subject: 'تقرير المبيعات');
      return true;
    } catch (e) {
      debugPrint('exportSalesCsv error: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════
  //  INVOICE PDF — طباعة فاتورة واحدة
  // ══════════════════════════════════════════════════════

  static Future<void> printInvoice({
    required Sale sale,
    required String shopName,
    String? shopPhone,
    String? shopAddress,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a5,
      textDirection: pw.TextDirection.rtl,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Center(child: pw.Text(shopName,
            style: pw.TextStyle(font: fontBold, fontSize: 20))),
          if (shopAddress != null)
            pw.Center(child: pw.Text(shopAddress,
              style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700))),
          if (shopPhone != null)
            pw.Center(child: pw.Text(shopPhone,
              style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700))),
          pw.SizedBox(height: 12),
          pw.Divider(thickness: 1.5),

          // Invoice info
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('رقم الفاتورة: ${sale.id.substring(0, 8).toUpperCase()}',
              style: pw.TextStyle(font: font, fontSize: 10)),
            pw.Text(DateFormat('yyyy/MM/dd – hh:mm a').format(sale.date),
              style: pw.TextStyle(font: font, fontSize: 10)),
          ]),
          pw.SizedBox(height: 8),

          // Items table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: ['الصنف', 'كمية', 'سعر', 'إجمالي']
                  .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: pw.Text(h, style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  )).toList(),
              ),
              // Items
              ...sale.items.map((item) => pw.TableRow(children: [
                _cell(item.productName, font),
                _cell('${item.quantity}', font),
                _cell('${item.unitPrice.toStringAsFixed(2)}', font),
                _cell('${item.total.toStringAsFixed(2)}', font),
              ])),
            ],
          ),
          pw.SizedBox(height: 8),

          // Totals
          pw.Divider(thickness: 0.5),
          if (sale.discount > 0) ...[
            _totalRow('الإجمالي قبل الخصم', sale.total.toStringAsFixed(2), font),
            _totalRow('الخصم', '- ${sale.discount.toStringAsFixed(2)}', font, color: PdfColors.red),
          ],
          _totalRow('الصافي', 'ج.م ${sale.netTotal.toStringAsFixed(2)}', fontBold, size: 14),
          pw.SizedBox(height: 4),
          _totalRow('طريقة الدفع', sale.paymentMethod, font, color: PdfColors.teal),
          pw.SizedBox(height: 16),
          pw.Center(child: pw.Text('شكراً لتعاملكم معنا',
            style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.grey600))),
        ],
      ),
    ));

    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  // ══════════════════════════════════════════════════════
  //  REPORT PDF — تقرير المبيعات
  // ══════════════════════════════════════════════════════

  static Future<void> printSalesReport({
    required List<Sale> sales,
    required String shopName,
    required double todayTotal,
    required double monthTotal,
    required Map<String, double> topProducts,
  }) async {
    final doc     = pw.Document();
    final font    = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();
    final now     = DateTime.now();

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (ctx) => [
        // Header
        pw.Center(child: pw.Text('تقرير المبيعات — $shopName',
          style: pw.TextStyle(font: fontBold, fontSize: 18))),
        pw.Center(child: pw.Text(DateFormat('yyyy/MM/dd').format(now),
          style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700))),
        pw.SizedBox(height: 16),

        // Summary
        pw.Row(children: [
          _summaryBox('مبيعات اليوم', 'ج.م ${todayTotal.toStringAsFixed(2)}', font, fontBold),
          pw.SizedBox(width: 12),
          _summaryBox('مبيعات الشهر', 'ج.م ${monthTotal.toStringAsFixed(2)}', font, fontBold),
          pw.SizedBox(width: 12),
          _summaryBox('إجمالي الفواتير', '${sales.length}', font, fontBold),
        ]),
        pw.SizedBox(height: 16),

        // Top products
        if (topProducts.isNotEmpty) ...[
          pw.Text('الأكثر مبيعاً', style: pw.TextStyle(font: fontBold, fontSize: 13)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: ['المنتج', 'الكمية المباعة']
                  .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(h, style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  )).toList(),
              ),
              ...topProducts.entries.take(10).map((e) => pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(e.key, style: pw.TextStyle(font: font, fontSize: 10))),
                pw.Padding(padding: const pw.EdgeInsets.all(6),
                  child: pw.Text('${e.value.toInt()} وحدة', style: pw.TextStyle(font: font, fontSize: 10))),
              ])),
            ],
          ),
          pw.SizedBox(height: 16),
        ],

        // Sales table
        pw.Text('سجل الفواتير', style: pw.TextStyle(font: fontBold, fontSize: 13)),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1.5),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: ['التاريخ', 'الصافي', 'الخصم', 'الدفع']
                .map((h) => pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(h, style: pw.TextStyle(font: fontBold, fontSize: 9)),
                )).toList(),
            ),
            ...sales.take(50).map((s) => pw.TableRow(children: [
              _cell(DateFormat('MM/dd HH:mm').format(s.date), font, size: 9),
              _cell('ج.م ${s.netTotal.toStringAsFixed(2)}', font, size: 9),
              _cell(s.discount > 0 ? 'ج.م ${s.discount.toStringAsFixed(2)}' : '-', font, size: 9),
              _cell(s.paymentMethod, font, size: 9),
            ])),
          ],
        ),
      ],
    ));

    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  // ══════════════════════════════════════════════════════
  //  Helpers
  // ══════════════════════════════════════════════════════

  static String _dateTag() => DateFormat('yyyyMMdd_HHmm').format(DateTime.now());

  static pw.Widget _cell(String text, pw.Font font, {double size = 10}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: size)),
    );

  static pw.Widget _totalRow(String label, String value, pw.Font font,
      {PdfColor? color, double size = 11}) =>
    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text(label, style: pw.TextStyle(font: font, fontSize: size, color: color)),
      pw.Text(value, style: pw.TextStyle(font: font, fontSize: size, color: color)),
    ]);

  static pw.Widget _summaryBox(String label, String value, pw.Font font, pw.Font bold) =>
    pw.Expanded(child: pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(children: [
        pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 14)),
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700)),
      ]),
    ));
}
