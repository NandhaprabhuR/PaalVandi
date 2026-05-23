import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cart_models.dart';
import '../viewmodels/cart_viewmodel.dart';

class CartBillPdfService {
  static Future<void> downloadBillPdf({
    required CartViewModel cart,
    required DateTime billDate,
  }) async {
    final doc = _buildDocument(cart: cart, billDate: billDate);
    final bytes = await doc.save();
    final fileName =
        'PaalVandi_Bill_${DateFormat('yyyyMMdd_HHmm').format(billDate)}.pdf';

    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  static pw.Document _buildDocument({
    required CartViewModel cart,
    required DateTime billDate,
  }) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(billDate);
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'PaalVandi',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Detailed Bill', style: const pw.TextStyle(fontSize: 16)),
          pw.Text('Date: $dateStr',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          pw.SizedBox(height: 16),
          pw.Divider(),
          pw.SizedBox(height: 12),
          ...cart.items.map(_lineItemBlock),
          pw.SizedBox(height: 16),
          pw.Divider(),
          _totalRow('Items subtotal', cart.itemsSubtotalRupees),
          _totalRow('Delivery charge', cart.deliveryChargeRupeesApplied),
          pw.SizedBox(height: 6),
          _totalRow('To pay', cart.toPayRupees, bold: true),
          pw.SizedBox(height: 24),
          pw.Text(
            'Thank you for choosing PaalVandi fresh dairy.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    return doc;
  }

  static pw.Widget _lineItemBlock(CartLineItem item) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 48,
            height: 48,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.blue200),
            ),
            child: pw.Center(
              child: pw.Text('Milk', style: const pw.TextStyle(fontSize: 9)),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  item.productName,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Text('Size: ${item.quantity}',
                    style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Qty: ${item.count}',
                    style: const pw.TextStyle(fontSize: 10)),
                pw.Text(
                  'Milk: Rs.${item.milkPriceRupees}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  item.deliveryMethod.billLine,
                  style: const pw.TextStyle(fontSize: 10),
                ),
                if (item.hasDeposit)
                  pw.Text(
                    'Deposit for glass bottle: Rs.${item.totalDepositRupees}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
              ],
            ),
          ),
          pw.Text(
            'Rs.${item.lineTotalRupees}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static pw.Widget _totalRow(String label, int amount, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: bold ? 13 : 11,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            'Rs.$amount',
            style: pw.TextStyle(
              fontSize: bold ? 14 : 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
