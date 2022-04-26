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

class SingleOrderPage extends StatefulWidget {
  const SingleOrderPage({Key key}) : super(key: key);

  @override
  _SingleOrderPageState createState() => _SingleOrderPageState();
}

class _SingleOrderPageState extends State<SingleOrderPage> {
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
          title: Text("Order"),
          backgroundColor: primary,
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     setState(() {});
        //   },
        //   backgroundColor: primary,
        //   child: Icon(Icons.refresh),
        // ),
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
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: Text(
                                  "#" + data[0].ticketNo.toString(),
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
                                            InvoicePage(data: data[0]),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.remove_red_eye_outlined,
                                  ),
                                ),
                                title: Text(
                                  data[0].invoiceNo.toString(),
                                  style: TextStyle(
                                    color: dark,
                                    fontSize: 32,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Date:- " + data[0].date.toString(),
                                      style: TextStyle(
                                        color: dark,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Status:- " + data[0].paymentStatus,
                                      style: TextStyle(
                                        color: dark,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Delivery Status:- " +
                                          data[0].deliveryStatus.toString(),
                                      style: TextStyle(
                                        color: dark,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          // Column(
                          //   children: data.map((order) {
                          //     return ;
                          //   }).toList(),
                          // ),
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
