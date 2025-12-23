import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:barcode_widget/barcode_widget.dart' as bw;
import '../models/produit.dart';
import '../config/app_constants.dart';

class LabelService {
  /// Generate product label PDF (80mm x 50mm)
  Future<Uint8List> genererLabelPDF(Produit produit, {int copies = 1}) async {
    final pdf = pw.Document();

    // Label format: 80mm x 50mm
    final labelFormat = PdfPageFormat(
      AppConstants.labelWidth * PdfPageFormat.mm,
      AppConstants.labelHeight * PdfPageFormat.mm,
      marginAll: 2 * PdfPageFormat.mm,
    );

    for (int i = 0; i < copies; i++) {
      pdf.addPage(
        pw.Page(
          pageFormat: labelFormat,
          build: (context) => pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                // Product name
                pw.Text(
                  produit.designation,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                  maxLines: 2,
                  overflow: pw.TextOverflow.clip,
                ),
                pw.SizedBox(height: 5),
                // Barcode
                pw.BarcodeWidget(
                  data: produit.barcode,
                  barcode: _getBarcodeType(produit.barcode),
                  width: 70 * PdfPageFormat.mm,
                  height: 20 * PdfPageFormat.mm,
                  drawText: true,
                  textStyle: const pw.TextStyle(fontSize: 8),
                ),
                pw.SizedBox(height: 5),
                // Price
                pw.Text(
                  'Prix: ${produit.prixUnitaire.toStringAsFixed(2)} ${AppConstants.currency}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),
                // Product code
                pw.Text(
                  'Code: ${produit.code}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return pdf.save();
  }

  /// Print product label
  Future<void> printLabel(Produit produit, {int copies = 1}) async {
    final pdfData = await genererLabelPDF(produit, copies: copies);
    await Printing.layoutPdf(
      onLayout: (format) async => pdfData,
      name: 'Etiquette_${produit.code}.pdf',
    );
  }

  /// Print multiple labels for different products
  Future<void> printMultipleLabels(List<Produit> produits) async {
    final pdf = pw.Document();

    final labelFormat = PdfPageFormat(
      AppConstants.labelWidth * PdfPageFormat.mm,
      AppConstants.labelHeight * PdfPageFormat.mm,
      marginAll: 2 * PdfPageFormat.mm,
    );

    for (final produit in produits) {
      pdf.addPage(
        pw.Page(
          pageFormat: labelFormat,
          build: (context) => pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  produit.designation,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                  maxLines: 2,
                  overflow: pw.TextOverflow.clip,
                ),
                pw.SizedBox(height: 5),
                pw.BarcodeWidget(
                  data: produit.barcode,
                  barcode: _getBarcodeType(produit.barcode),
                  width: 70 * PdfPageFormat.mm,
                  height: 20 * PdfPageFormat.mm,
                  drawText: true,
                  textStyle: const pw.TextStyle(fontSize: 8),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Prix: ${produit.prixUnitaire.toStringAsFixed(2)} ${AppConstants.currency}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Code: ${produit.code}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final pdfData = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (format) async => pdfData,
      name: 'Etiquettes_produits.pdf',
    );
  }

  /// Get appropriate barcode type based on barcode length
  pw.Barcode _getBarcodeType(String barcode) {
    final length = barcode.length;
    
    if (length == 13) {
      return pw.Barcode.ean13();
    } else if (length == 8) {
      return pw.Barcode.ean8();
    } else if (length == 12) {
      return pw.Barcode.upcA();
    } else {
      // Default to Code128 for variable length barcodes
      return pw.Barcode.code128();
    }
  }
}
