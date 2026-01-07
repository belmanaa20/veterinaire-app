import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/facture.dart';
import '../models/parametres.dart';
import '../config/app_constants.dart';

class PdfService {
  final DateFormat _dateFormat = DateFormat(AppConstants.pdfDateFormat);

  /// Generate facture PDF (A4 format)
  Future<Uint8List> genererFacturePDF(
    Facture facture, {
    Parametres? parametres,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(AppConstants.pdfMargin),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(parametres),
            pw.SizedBox(height: 20),
            _buildFactureTitle(facture.numero),
            pw.SizedBox(height: 20),
            _buildClientAndDateInfo(facture),
            pw.SizedBox(height: 20),
            _buildProductsTable(facture),
            pw.SizedBox(height: 20),
            _buildTotal(facture.montantTotal),
            pw.SizedBox(height: 10),
            _buildAmountInWords(facture.montantTotal),
            pw.Spacer(),
            _buildSignature(parametres),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  /// Print facture PDF
  Future<void> printFacturePDF(Facture facture, {Parametres? parametres}) async {
    final pdfData = await genererFacturePDF(facture, parametres: parametres);
    await Printing.layoutPdf(
      onLayout: (format) async => pdfData,
      name: 'Facture_${facture.numero}.pdf',
    );
  }

  /// Share facture PDF
  Future<void> shareFacturePDF(Facture facture, {Parametres? parametres}) async {
    final pdfData = await genererFacturePDF(facture, parametres: parametres);
    await Printing.sharePdf(
      bytes: pdfData,
      filename: 'Facture_${facture.numero}.pdf',
    );
  }

  // Build header with logo and shop info
  pw.Widget _buildHeader(Parametres? parametres) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Logo placeholder
          pw.Container(
            width: 80,
            height: 80,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Center(
              child: pw.Text(
                'LOGO',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey500,
                ),
              ),
            ),
          ),
          // Shop information
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                parametres?.nomMagasin ?? 'PHARMACIE VÉTÉRINAIRE',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (parametres?.adresse != null) ...[
                pw.SizedBox(height: 5),
                pw.Text(
                  parametres!.adresse!,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
              if (parametres?.telephone != null) ...[
                pw.SizedBox(height: 3),
                pw.Text(
                  'Tél: ${parametres!.telephone}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
              if (parametres?.nif != null) ...[
                pw.SizedBox(height: 3),
                pw.Text(
                  'NIF: ${parametres!.nif}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Build facture title
  pw.Widget _buildFactureTitle(String numero) {
    return pw.Center(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: pw.BoxDecoration(
          color: PdfColors.blue900,
        ),
        child: pw.Text(
          'FACTURE N°: $numero',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      ),
    );
  }

  // Build client and date information
  pw.Widget _buildClientAndDateInfo(Facture facture) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Client info
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'CLIENT',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Nom: ${facture.client?.nom ?? 'N/A'}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                if (facture.client?.adresse != null) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Adresse: ${facture.client!.adresse}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
                if (facture.client?.telephone != null) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Tél: ${facture.client!.telephone}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
                if (facture.client?.culture != null) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Culture: ${facture.client!.culture}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
          // Date info
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'INFORMATIONS',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Date: ${_dateFormat.format(facture.dateFacture)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Échéance: ${_dateFormat.format(facture.dateEcheance)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Statut: ${facture.statut}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build products table
  pw.Widget _buildProductsTable(Facture facture) {
    final lignes = facture.lignes ?? [];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('N°', isHeader: true),
            _buildTableCell('DÉSIGNATION', isHeader: true),
            _buildTableCell('DATE AJOUT', isHeader: true),
            _buildTableCell('QTÉ', isHeader: true),
            _buildTableCell('P.U (${AppConstants.currency})', isHeader: true),
            _buildTableCell('MONTANT (${AppConstants.currency})', isHeader: true),
          ],
        ),
        // Rows
        ...lignes.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final ligne = entry.value;
          return pw.TableRow(
            children: [
              _buildTableCell(index.toString()),
              _buildTableCell(ligne.produitDesignation ?? 'N/A'),
              _buildTableCell(_dateFormat.format(ligne.dateAjout)),
              _buildTableCell(ligne.quantite.toStringAsFixed(2)),
              _buildTableCell(ligne.prixUnitaire.toStringAsFixed(2)),
              _buildTableCell(ligne.montant.toStringAsFixed(2)),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Build table cell
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  // Build total
  pw.Widget _buildTotal(double montantTotal) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Text(
        'TOTAL: ${montantTotal.toStringAsFixed(2)} ${AppConstants.currency}',
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  // Build amount in words
  pw.Widget _buildAmountInWords(double montant) {
    final amountInWords = _convertNumberToWords(montant);
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Text(
        'Arrêté la présente facture à la somme de: $amountInWords',
        style: pw.TextStyle(
          fontSize: 10,
          fontStyle: pw.FontStyle.italic,
        ),
      ),
    );
  }

  // Build signature
  pw.Widget _buildSignature(Parametres? parametres) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        // Signature
        pw.Column(
          children: [
            pw.Text(
              'Signature',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              width: 100,
              height: 60,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Center(
                child: pw.Text(
                  'SIGNATURE',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey400,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Cachet
        pw.Column(
          children: [
            pw.Text(
              'Cachet',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              width: 100,
              height: 60,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Center(
                child: pw.Text(
                  'CACHET',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Convert number to words (French)
  String _convertNumberToWords(double amount) {
    // Simplified version - in a real app, use a proper number-to-words library
    final intPart = amount.floor();
    final decPart = ((amount - intPart) * 100).round();
    
    if (decPart > 0) {
      return '$intPart dinars et $decPart centimes';
    } else {
      return '$intPart dinars';
    }
  }
}
