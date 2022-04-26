import 'package:flutter/material.dart';
// import 'package:poppos/Componant/InputField.dart';
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Model/Auth.dart';
import 'package:poppos/Model/OfflineModel.dart';
import 'package:poppos/Model/OrderModel.dart';
import 'package:poppos/Networking/OfflineData.dart';
import 'package:poppos/Utills/Color.dart';
import 'package:poppos/View/InvoicePage.dart';
import 'package:poppos/View/Pos.dart';

import '../main.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool flag = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => POSPage(),
                  )),
              icon: Icon(Icons.arrow_back)),
          title: Text("All Orders"),
          backgroundColor: primary,
          actions: [
            // IconButton(
            //   onPressed: () {
            //     setState(() {
            //       flag = !flag;
            //     });
            //   },
            //   icon: Icon(Icons.search),
            // ),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {});
          },
          backgroundColor: primary,
          child: Icon(Icons.refresh),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // if (flag) InputField(),
              SizedBox(
                height: 24,
              ),
              FutureBuilder(
                future: getOrderData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    List<Order> data = snapshot.data;

                    if (data.length > 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 64.0),
                        child: Column(
                          children: data.map((order) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  leading: Text(
                                    "#" + order.ticketNo.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 32,
                                    ),
                                  ),
                                  trailing: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(primary),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              InvoicePage(data: order),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.remove_red_eye_outlined,
                                    ),
                                  ),
                                  title: Text(
                                    order.invoiceNo.toString(),
                                    style: TextStyle(
                                      color: dark,
                                      fontSize: 32,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Date:- " + order.date.toString(),
                                        style: TextStyle(
                                          color: dark,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "Status:- " + order.paymentStatus,
                                        style: TextStyle(
                                          color: dark,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "Delivery Status:- " +
                                            order.deliveryStatus.toString(),
                                        style: TextStyle(
                                          color: dark,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "No Order Found",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: primary,
                        valueColor: AlwaysStoppedAnimation(
                          secondary,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
