import "package:flutter/material.dart";
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:poppos/Model/OrderModel.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

class PrintPage extends StatelessWidget {
  final Order data;
  final double width;
  const PrintPage({
    Key key,
    this.data,
    this.width,
  }) : super(key: key);

  print() {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text('Hello World'),
          ); // Center
        },
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Invoice No. " + data.invoiceNo.toString(),
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  "Ticket No. " + data.ticketNo.toString(),
                  style: pw.TextStyle(
                    fontSize: 16,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                pw.SizedBox(
                  height: 24,
                ),
                pw.Text(
                  "Details",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  "Invoice date: " + data.date.toString(),
                  style: pw.TextStyle(
                    fontSize: 16,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                pw.Text(
                  "Delivery Status: " + data.deliveryStatus,
                  style: pw.TextStyle(
                    fontSize: 16,
                  ),
                ),
                pw.SizedBox(
                  height: 24,
                ),
                pw.SizedBox(
                  height: 40,
                ),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: width / 3,
                    // width: 250,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Subtotal:"),
                            pw.Text(data.subtotal.toString() + " AED"),
                          ],
                        ),
                        pw.SizedBox(height: 24),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("VAT:"),
                            pw.Text(data.vat.toString() + " AED"),
                          ],
                        ),
                        pw.SizedBox(height: 24),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Discount:"),
                            pw.Text(data.discount.toString() + " AED"),
                          ],
                        ),
                        pw.Divider(
                          thickness: 2,
                        ),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Total:"),
                            pw.Text(data.total.toString() + " AED"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),
                // pw.Flexible(
                //   child: pw.FlutterLogo(),
                // )
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("title")),
        body: PdfPreview(
          build: (format) => _generatePdf(format, "title"),
        ),
      ),
    );
  }
}
