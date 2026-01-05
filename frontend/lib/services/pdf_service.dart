import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateReport(
    Map<String, dynamic> data,
    File imageFile,
  ) async {
    final pdf = pw.Document();

    // Load image from file (printing's imageFromAssetBundle is for assets, so we use MemoryImage for File)
    final netImage = pw.MemoryImage(imageFile.readAsBytesSync());

    // Fonts (optional: loading custom fonts if needed, using standard for now)

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Lung Cancer Detection Report",
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(DateTime.now().toString().split('.')[0]),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Image Section
              pw.Container(
                height: 200,
                alignment: pw.Alignment.center,
                child: pw.Image(netImage, fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(height: 20),

              // Result Section
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue, width: 2),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Prediction Result",
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue,
                      ),
                    ),
                    pw.Divider(color: PdfColors.blue),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "Diagnosis:",
                          style: pw.TextStyle(fontSize: 16),
                        ),
                        pw.Text(
                          data['prediction'].toString().toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: data['prediction'] == 'Malignant'
                                ? PdfColors.red
                                : PdfColors.green,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "Confidence:",
                          style: pw.TextStyle(fontSize: 16),
                        ),
                        pw.Text(
                          "${(data['confidence'] * 100).toStringAsFixed(2)}%",
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Detailed Analysis Table
              pw.Text(
                "Detailed Probabilities",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(),
                headerAlignment: pw.Alignment.centerLeft,
                headers: <String>['Condition', 'Probability'],
                data: <List<String>>[
                  [
                    'Normal / Healthy',
                    "${((data['probabilities']['Normal'] ?? 0.0) * 100).toStringAsFixed(4)}%",
                  ],
                  [
                    'Benign (Non-Cancerous)',
                    "${((data['probabilities']['Benign'] ?? 0.0) * 100).toStringAsFixed(4)}%",
                  ],
                  [
                    'Malignant (Cancerous)',
                    "${((data['probabilities']['Malignant'] ?? 0.0) * 100).toStringAsFixed(4)}%",
                  ],
                ],
              ),

              pw.Spacer(),

              // Footer / Disclaimer
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                color: PdfColors.grey200,
                child: pw.Text(
                  "DISCLAIMER: This report is generated by an AI system and is NOT a medical diagnosis. Please consult a qualified healthcare professional.",
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Print/Share
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Lung_Cancer_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}
