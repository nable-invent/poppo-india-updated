import 'package:flutter/material.dart';
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Model/Auth.dart';
import 'package:poppos/Model/OfflineModel.dart';
import 'package:poppos/Model/OrderModel.dart';
import 'package:poppos/Networking/OfflineData.dart';
import 'package:poppos/Utills/Color.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../main.dart';
import 'html.dart';

class InvoicePage extends StatelessWidget {
  final Order data;
  const InvoicePage({
    Key key,
    this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Invoice"),
          backgroundColor: primary,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: TextButton(
                    onPressed: () async {
                      await logout();
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => MyApp(),
                        ),
                        ModalRoute.withName('/'),
                      );
                    },
                    child: Text(
                      "Logout",
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: TextButton(
                    onPressed: () async {
                      await DatabaseHelper.instance.truncateCart();
                      String outlet = await getOfflineData("outlet");
                      await appOffline(outlet);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Sync Data",
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            )
            // Builder(
            //   builder: (context) => IconButton(
            //     icon: Icon(
            //       Icons.add_shopping_cart_outlined,
            //       size: 36,
            //     ),
            //     onPressed: () => Scaffold.of(context).openEndDrawer(),
            //     tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            //   ),
            // ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              dark.withOpacity(0.7),
                            ),
                          ),
                          onPressed: () async {
                            String dim = await invoiceGenerator(data);
                            Printing.layoutPdf(
                              onLayout: (PdfPageFormat format) async =>
                                  await Printing.convertHtml(
                                format: format,
                                html: dim,
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.print,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text("print"),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        "Invoice No. " + data.invoiceNo.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Ticket No. " + data.ticketNo.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        "Details",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Invoice date: " + data.date.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Delivery Status: " + data.deliveryStatus,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          // columnSpacing: width / 12,
                          dividerThickness: 1,
                          columns: <DataColumn>[
                            DataColumn(
                              label: Text(
                                "#",
                                textScaleFactor: 1,
                              ),
                              tooltip: "S/No.",
                            ),
                            DataColumn(
                              label: Text("Item"),
                            ),
                            DataColumn(
                              label: Text("Quantity"),
                            ),
                            DataColumn(
                              label: Text("Subtotal"),
                            ),
                            DataColumn(
                              label: Text("VAT Amount"),
                            ),
                            DataColumn(
                              label: Text("Total"),
                            ),
                          ],
                          rows: data.productList.map(
                            (e) {
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(
                                    Text(e.sNo.toString() ?? ""),
                                  ),
                                  DataCell(
                                    Text(e.name ?? ""),
                                  ),
                                  DataCell(
                                    Text(e.quantity.toString() ?? ""),
                                  ),
                                  DataCell(
                                    Text(e.subTotal.toString() + " AED"),
                                  ),
                                  DataCell(
                                    Text(e.vatAmount.toString() + " AED"),
                                  ),
                                  DataCell(
                                    Text(e.total.toString() + " AED"),
                                  ),
                                ],
                              );
                            },
                          ).toList(),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              width: width / 3,
                              // width: 250,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Subtotal:"),
                                      Text(data.subtotal.toString() + " AED"),
                                    ],
                                  ),
                                  SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("VAT:"),
                                      Text(data.vat.toString() + " AED"),
                                    ],
                                  ),
                                  SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Discount:"),
                                      Text(data.discount.toString() + " AED"),
                                    ],
                                  ),
                                  Divider(
                                    thickness: 2,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Total:"),
                                      Text(data.total.toString() + " AED"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
