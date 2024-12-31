import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExportToPdf {
  static Future<void> exportTableToPdf(
    List<dynamic> data,
    Map<String, String> headerTitles,
    String title,
  ) async {
    final pdf = pw.Document();
    final headers = headerTitles.values.toList();
    final tableData = data.map((item) => headerTitles.keys.map((key) => item[key].toString()).toList()).toList();

    final fontDataRegular = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttfRegular = pw.Font.ttf(fontDataRegular);
    final fontDataBold = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final ttfBold = pw.Font.ttf(fontDataBold);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'EXCHANGER',
              style: pw.TextStyle(font: ttfBold, fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              title,
              style: pw.TextStyle(font: ttfRegular, fontSize: 22),
            ),          
            pw.SizedBox(height: 8),
            pw.Text(
              DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
              style: pw.TextStyle(font: ttfRegular, fontSize: 18),
            ),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: headers,
              data: tableData,
              cellStyle: pw.TextStyle(font: ttfRegular),
              headerStyle: pw.TextStyle(font: ttfRegular, fontWeight: pw.FontWeight.bold),
              headerAlignment: pw.Alignment.center,
              cellAlignment: pw.Alignment.center,
            ),
          ],
        ),
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final now = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
    final file = File("${output.path}/report_$now.pdf");
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }
}