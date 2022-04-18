// class Orders {
//   final int orderId;
//   final int customerId;
//   final String invoiceNumber;
//   final String invoiceDate;
//   final String ticketNo;
//   final double grossTotal;

//   final String productName;
//   final double price;
//   final double tax;
//   int count;
//   Orders({
//     this.orderId,
//     this.productId,
//     this.productName,
//     this.price,
//     this.tax,
//     this.count,
//   });
// }
// nothing just to create branch

import 'dart:convert';

import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Networking/ModelToDB.dart';
import 'package:poppos/Networking/Networking.dart';
import 'package:poppos/Networking/OfflineData.dart';
// import 'package:poppos/View/DummyPage.dart';
import 'package:http/http.dart' as http;
import 'CartProduct.dart';
import 'Posmodel.dart';
import 'Url.dart';
import 'package:localstorage/localstorage.dart';

addData(Map<String, dynamic> data, String key) async {
  final LocalStorage storage = new LocalStorage('order.json');
  await storage.ready;
  storage.setItem("$key", data);
}

getData(String key) async {
  final LocalStorage storage = LocalStorage('order.json');
  await storage.ready;
  print(storage.getItem(key));
  return storage.getItem(key);
}

removeData(String key) async {
  final LocalStorage storage = LocalStorage('order.json');
  await storage.ready;
  return storage.deleteItem(key);
}

placeOrder({
  String cardNumber = "1234567899",
  String cardType = "Visa",
  String cardAmount = "0",
  String cashAmount = "0",
  int customerId = 0,
  double discount = 18,
  double discountAmount = 0,
  String discountType = "DISCOUNT_BY_PERCENTAGE",
  int driverId = 0,
  String payType,
  double subTotal = 0,
  double total = 0,
  double totalTax = 0,
  // BuildContext context,
}) async {
  Map<String, dynamic> map = {
    "paytype": payType,
    "subtotal": subTotal,
    "total": total,
    "totalTax": totalTax,
    "discount": discount,
    "discountedAmount": discountAmount,
    "discountType": discountType,
  };
  Map<String, dynamic> payment = {};
  if (payType == "Cash" || payType == "Cash & card") {
    payment.addAll({
      "cashAmount": double.parse(cashAmount),
    });
  }
  if (payType == "Card" || payType == "Cash & card") {
    payment.addAll({
      "card_number": cardNumber,
      "card_type": cardType,
      "cardAmount": double.parse(cardAmount),
    });
  }
  if (payType == "Delivery company") {
    payment.addAll({
      "card_number": cardNumber,
    });
  }

  List<CartProduct> data = await DatabaseHelper.instance.queryCart();
  print("product code " + data[0].productCode);
  List<dynamic> invoiceData = [];
  int i = 1;
  for (dynamic res in data) {
    double gross = double.parse(res.price) * res.count;
    double net = gross;
    // dynamic category =
    Map<String, dynamic> dim = {
      "category": res.productCat,
      "gross_total": gross,
      "id": res.productId,
      "item_code": res.productCode,
      "net_amount": net,
      "quantity": res.count,
      "s_no": i++,
      "vat_amount": res.tax,
    };
    invoiceData.add(dim);
  }
  map.addAll(payment);
  map['invoice'] = {
    "invoiceProducts": invoiceData,
  };
  if (await checkConnectivity()) {
    bool session = await getPosdata();
    // try {

    if (!session) {
      // Dio dio = Dio();

      print(invoiceData);
      int posId = await getPosdataId();
      String token = await getOfflineData("token");
      String outlet = await getOfflineData("outlet");
      String apiData = await getOfflineData("url");
      print(
        api +
            apiData +
            routes(key: "createorder") +
            outlet +
            "&pos_id=" +
            posId.toString(),
      );

      var body = jsonEncode(map);
      final response = await http.post(
        Uri.parse(
          api +
              apiData +
              routes(key: "createorder") +
              outlet +
              "&pos_id=" +
              posId.toString(),
        ),
        headers: {
          "Authorization": "Token " + token,
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        DatabaseHelper.instance.truncateCart();
        Fluttertoast.showToast(msg: "Order Created Successfully");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Order Creation fail");
        return false;
      }
    } else {
      Fluttertoast.showToast(msg: "No Pos session found");
      return false;
    }
  } else {
    String key = DateTime.now().toString();
    await createDataList();
    await DatabaseHelper.instance.insertTable(
      {
        "key": key,
      },
      "tbl_datalist",
    );
    addData(map, "$key");
    DatabaseHelper.instance.truncateCart();
    Fluttertoast.showToast(msg: "Order Created Successfully");
    return true;
  }
}

fetchData() async {
  List<Map<String, dynamic>> data =
      await DatabaseHelper.instance.queryAllTableData(table: "tbl_datalist");
  if (await checkConnectivity()) {
    bool session = await getPosdata();
    // try {

    if (!session) {
      // Dio dio = Dio();
      int posId = await getPosdataId();
      String token = await getOfflineData("token");
      String outlet = await getOfflineData("outlet");
      String apiData = await getOfflineData("url");
      for (dynamic i in data) {
        dynamic map = await getData(i['key']);
        var body = jsonEncode(map);
        final response = await http.post(
          Uri.parse(
            api +
                apiData +
                routes(key: "createorder") +
                outlet +
                "&pos_id=" +
                posId.toString(),
          ),
          headers: {
            "Authorization": "Token " + token,
            "content-type": "application/json",
            "accept": "application/json",
          },
          body: body,
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          await DatabaseHelper.instance.deleteTableData(
              i['tbl_datalist_id'], 'tbl_datalist_id', "tbl_datalist");
          await removeData(i['key']);
        }
      }
    }
  } else {
    Fluttertoast.showToast(msg: "Please Check Your Internet Connectivity");
  }
}

fetchDataBG() async {
  List<Map<String, dynamic>> data =
      await DatabaseHelper.instance.queryAllTableData(table: "tbl_datalist");
  if (await checkConnectivity()) {
    bool session = await getPosdata();
    // try {

    if (!session) {
      // Dio dio = Dio();
      int posId = await getPosdataId();
      String token = await getOfflineData("token");
      String outlet = await getOfflineData("outlet");
      String apiData = await getOfflineData("url");
      for (dynamic i in data) {
        dynamic map = await getData(i['key']);
        var body = jsonEncode(map);
        final response = await http.post(
          Uri.parse(
            api +
                apiData +
                routes(key: "createorder") +
                outlet +
                "&pos_id=" +
                posId.toString(),
          ),
          headers: {
            "Authorization": "Token " + token,
            "content-type": "application/json",
            "accept": "application/json",
          },
          body: body,
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          await DatabaseHelper.instance.deleteTableData(
              i['tbl_datalist_id'], 'tbl_datalist_id', "tbl_datalist");
          await removeData(i['key']);
        }
      }
    }
  }
}

removeAllOrder() async {
  List<Map<String, dynamic>> data =
      await DatabaseHelper.instance.queryAllTableData(table: "tbl_datalist");
  for (dynamic i in data) {
    await DatabaseHelper.instance.deleteTableData(
        i['tbl_datalist_id'], 'tbl_datalist_id', "tbl_datalist");
    await removeData(i['key']);
  }
}

createDataList() async {
  List<Table> column = [];
  Table id = Table(
    columnName: "key",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(id);
  await DatabaseHelper.instance.createTable("tbl_datalist", column);
}

class Order {
  final int orderId;
  final int ticketNo;
  final String invoiceNo;
  final String date;
  final String paymentStatus;
  final String deliveryStatus;
  final String discount;
  final String paytype;
  final String subtotal;
  final String vat;
  final String total;
  final List<OrderProduct> productList;
  Order({
    this.orderId,
    this.ticketNo,
    this.invoiceNo,
    this.date,
    this.paymentStatus,
    this.productList,
    this.deliveryStatus,
    this.discount,
    this.paytype,
    this.subtotal,
    this.total,
    this.vat,
  });
}

class OrderProduct {
  final int productId;
  final int sNo;
  final String name;
  final int quantity;
  final String subTotal;
  final String vatAmount;
  final String total;
  OrderProduct({
    this.productId,
    this.name,
    this.quantity,
    this.subTotal,
    this.vatAmount,
    this.total,
    this.sNo,
  });
}

Future<List<Order>> getOrderData() async {
  List<Order> orderList = [];
  if (await checkConnectivity()) {
    try {
      Dio dio = Dio();
      String token = await getOfflineData("token");
      String outlet = await getOfflineData("outlet");
      String apiData = await getOfflineData("url");
      dynamic response = await dio.get(
        api + apiData + routes(key: "orderlist") + outlet,
        options: Options(
          headers: {
            "Authorization": "Token " + token,
          },
        ),
      );
      if (response.statusCode == 200) {
        await createOrder();
        await createOrderProduct();
        await DatabaseHelper.instance.truncateTable("tbl_order");
        await DatabaseHelper.instance.truncateTable("tbl_orderproduct");
        dynamic data = response.data;
        for (dynamic res in data) {
          List<OrderProduct> order = [];
          int i = 1;
          for (dynamic prod in res['invdetails']) {
            OrderProduct o = OrderProduct(
              sNo: i++,
              productId: prod['product']['id'],
              name: prod['product']['name'],
              quantity: prod['quantity'],
              subTotal: prod['gross_total'],
              total: prod['net_amount'],
              vatAmount: prod['vat_amount'],
            );
            order.add(o);
            DatabaseHelper.instance.insertTable(
              {
                "sNo": i++,
                "productId": prod['product']['id'],
                "name": prod['product']['name'],
                "quantity": prod['quantity'],
                "subTotal": prod['gross_total'],
                "total": prod['net_amount'],
                "vatAmount": prod['vat_amount'],
                "order_id": res['id'],
              },
              "tbl_orderproduct",
            );
          }
          for (dynamic prod in res['combo_invdetails']) {
            OrderProduct o = OrderProduct(
              sNo: i++,
              productId: prod['id'],
              name: prod['combo'],
              quantity: prod['quantity'],
              subTotal: prod['gross_total'],
              total: prod['net_amount'],
              vatAmount: prod['vat_amount'],
            );
            DatabaseHelper.instance.insertTable(
              {
                "sNo": i++,
                "productId": prod['id'],
                "name": prod['combo'],
                "quantity": prod['quantity'],
                "subTotal": prod['gross_total'],
                "total": prod['net_amount'],
                "vatAmount": prod['vat_amount'],
                "order_id": res['id'],
              },
              "tbl_orderproduct",
            );
            order.add(o);
          }
          Order ord = Order(
            orderId: res['id'],
            invoiceNo: res['invoice_number'],
            paymentStatus: res['payment_status'],
            date: res['invoice_date'],
            ticketNo: res['ticket_no'],
            deliveryStatus: res['delivery_status'],
            discount: res['discount'],
            paytype: res['paytype'],
            subtotal: res['gross_total'],
            total: res['net_total'],
            vat: res['vat_amount'],
            productList: order,
          );
          orderList.add(ord);
          DatabaseHelper.instance.insertTable(
            {
              "id": res['id'],
              "invoice_number": res['invoice_number'],
              "payment_status": res['payment_status'],
              "invoice_date": res['invoice_date'],
              "ticket_no": res['ticket_no'],
              "delivery_status": res['delivery_status'],
              "discount": res['discount'],
              "paytype": res['paytype'],
              "gross_total": res['gross_total'],
              "net_total": res['net_total'],
              "vat_amount": res['vat_amount'],
            },
            "tbl_order",
          );
        }
      }
    } catch (e) {
      print(e);
    }
  } else {
    // print((await getOrder()).length.toString());
    return await getOrder();
  }

  return orderList;
}

getOrder() async {
  List<Order> orderList = [];
  // try {
  List<Map<String, dynamic>> order =
      await DatabaseHelper.instance.queryAllTableData(table: "tbl_order");
  // print(order);
  for (dynamic res in order) {
    List<Map<String, dynamic>> productData =
        await DatabaseHelper.instance.queryAllTableWhereData(
      table: "tbl_orderproduct",
      key: "order_id",
      id: res['id'],
    );
    List<OrderProduct> productList = [];
    for (dynamic r in productData) {
      OrderProduct prod = OrderProduct(
        sNo: r['sNo'],
        productId: int.parse(r['productId']),
        name: r['name'].toString(),
        quantity: int.parse(r['quantity']),
        subTotal: r['subTotal'].toString(),
        total: r['total'].toString(),
        vatAmount: r['vatAmount'].toString(),
      );
      productList.add(prod);
    }
    Order ord = Order(
      orderId: res['id'],
      ticketNo: int.parse(res['ticket_no']),
      invoiceNo: res['invoice_number'].toString(),
      date: res['invoice_date'].toString(),
      paymentStatus: res['payment_status'].toString(),
      deliveryStatus: res['delivery_status'].toString(),
      discount: res['discount'].toString(),
      paytype: res['paytype'].toString(),
      subtotal: res['gross_total'].toString(),
      total: res['net_total'].toString(),
      vat: res['vat_amount'].toString(),
      productList: productList,
    );
    orderList.add(ord);
  }
  // } catch (e) {
  //   print(e.error);
  // }

  return orderList;
}

createOrder() async {
  List<Table> column = [];
  Table id = Table(
    columnName: "id",
    columnType: checkdataType("int"),
    isNull: " NULL",
  );
  column.add(id);
  Table invoiceNumber = Table(
    columnName: "invoice_number",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(invoiceNumber);
  Table mobileNo = Table(
    columnName: "payment_status",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(mobileNo);
  Table invoiceDate = Table(
    columnName: "invoice_date",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(invoiceDate);
  Table ticketNo = Table(
    columnName: "ticket_no",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(ticketNo);
  Table deliveryStatus = Table(
    columnName: "delivery_status",
    columnType: checkdataType("int"),
    isNull: "NOT NULL",
  );
  column.add(deliveryStatus);
  Table discount = Table(
    columnName: "discount",
    columnType: checkdataType("int"),
    isNull: "NOT NULL",
  );
  column.add(discount);
  Table paytype = Table(
    columnName: "paytype",
    columnType: checkdataType("int"),
    isNull: "NOT NULL",
  );
  column.add(paytype);
  Table grossTotal = Table(
    columnName: "gross_total",
    columnType: checkdataType("int"),
    isNull: "NOT NULL",
  );
  column.add(grossTotal);
  Table netTotal = Table(
    columnName: "net_total",
    columnType: checkdataType("int"),
    isNull: "NOT NULL",
  );
  column.add(netTotal);
  Table vatAmount = Table(
    columnName: "vat_amount",
    columnType: checkdataType("int"),
    isNull: "NOT NULL",
  );
  column.add(vatAmount);

  await DatabaseHelper.instance.createTable("tbl_order", column);
}

createOrderProduct() async {
  List<Table> column = [];
  Table sNo = Table(
    columnName: "sNo",
    columnType: checkdataType("int"),
    isNull: " NULL",
  );
  column.add(sNo);
  Table productId = Table(
    columnName: "productId",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(productId);
  Table name = Table(
    columnName: "name",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(name);
  Table quantity = Table(
    columnName: "quantity",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(quantity);
  Table subTotal = Table(
    columnName: "subTotal",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(subTotal);
  Table total = Table(
    columnName: "total",
    columnType: checkdataType("String"),
    isNull: "NULL",
  );
  column.add(total);
  Table vatAmount = Table(
    columnName: "vatAmount",
    columnType: checkdataType("String"),
    isNull: "NULL",
  );
  column.add(vatAmount);
  Table orderId = Table(
    columnName: "order_id",
    columnType: checkdataType("String"),
    isNull: "NULL",
  );
  column.add(orderId);

  await DatabaseHelper.instance.createTable("tbl_orderproduct", column);
}

createOrderOffline() async {
  List<Table> column = [];
  Table id = Table(
    columnName: "id",
    columnType: checkdataType("int"),
    isNull: " NULL",
  );

  column.add(id);
  Table orderid = Table(
    columnName: "orderid",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );

  column.add(orderid);
  Table totalTax = Table(
    columnName: "totaltax",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(totalTax);

  Table discountAmount = Table(
    columnName: "discountedAmount",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(discountAmount);

  Table cashAmount = Table(
    columnName: "cashAmount",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(cashAmount);

  Table cardNumber = Table(
    columnName: "cardNumber",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(cardNumber);

  Table cardType = Table(
    columnName: "cardType",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(cardType);

  Table cardAmount = Table(
    columnName: "cardAmount",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(cardAmount);

  Table invoiceNumber = Table(
    columnName: "invoice_number",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(invoiceNumber);
  Table mobileNo = Table(
    columnName: "payment_status",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(mobileNo);
  Table invoiceDate = Table(
    columnName: "invoice_date",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(invoiceDate);
  Table ticketNo = Table(
    columnName: "ticket_no",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(ticketNo);
  Table deliveryStatus = Table(
    columnName: "deliveryStatus",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(deliveryStatus);
  Table discount = Table(
    columnName: "discount",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(discount);
  Table discountType = Table(
    columnName: "discountType",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(discountType);
  Table paytype = Table(
    columnName: "paytype",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(paytype);
  Table grossTotal = Table(
    columnName: "gross_total",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(grossTotal);
  Table netTotal = Table(
    columnName: "net_total",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(netTotal);
  Table vatAmount = Table(
    columnName: "vat_amount",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(vatAmount);
  Table status = Table(
    columnName: "status",
    columnType: checkdataType("int"),
    isNull: " NULL",
  );
  column.add(status);

  await DatabaseHelper.instance.createTable("tbl_orderOffline", column);
}

createOrderProductOffline() async {
  List<Table> column = [];
  Table sNo = Table(
    columnName: "category",
    columnType: checkdataType("int"),
    isNull: " NULL",
  );
  column.add(sNo);
  Table productId = Table(
    columnName: "productId",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(productId);
  Table name = Table(
    columnName: "name",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(name);
  Table itemcode = Table(
    columnName: "item_code",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(itemcode);
  Table quantity = Table(
    columnName: "quantity",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(quantity);
  Table subTotal = Table(
    columnName: "gross_total",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(subTotal);
  Table netamount = Table(
    columnName: "net_amount",
    columnType: checkdataType("String"),
    isNull: "NULL",
  );
  column.add(netamount);
  Table vatAmount = Table(
    columnName: "vat_amount",
    columnType: checkdataType("String"),
    isNull: "NULL",
  );
  column.add(vatAmount);
  Table orderId = Table(
    columnName: "order_id",
    columnType: checkdataType("String"),
    isNull: "NULL",
  );
  column.add(orderId);

  await DatabaseHelper.instance.createTable("tbl_orderproductOffline", column);
}

syncOrder() async {}
placeOrderSysnc({
  String cardNumber = "",
  String cardType = "Visa",
  String cardAmount = "0",
  String cashAmount = "0",
  int customerId = 0,
  double discount = 18,
  double discountAmount = 0,
  String discountType = "DISCOUNT_BY_PERCENTAGE",
  int driverId = 0,
  String payType,
  double subTotal = 0,
  double total = 0,
  double totalTax = 0,
  // BuildContext context,
}) async {
  if (await checkConnectivity()) {
    bool session = await getPosdata();
    if (!session) {
      Map<String, dynamic> map = {
        "paytype": payType,
        "subtotal": subTotal,
        "total": total,
        "totalTax": totalTax,
        "discount": discount,
        "discountedAmount": discountAmount,
        "discountType": discountType,
      };
      Map<String, dynamic> payment = {};
      if (payType == "Cash" || payType == "Cash & card") {
        payment.addAll({
          "cashAmount": double.parse(cashAmount),
        });
      }
      if (payType == "Card" || payType == "Cash & card") {
        payment.addAll({
          "card_number": cardNumber,
          "card_type": cardType,
          "cardAmount": double.parse(cardAmount),
        });
      }
      if (payType == "Delivery company") {
        payment.addAll({
          "card_number": cardNumber,
        });
      }

      List<CartProduct> data = await DatabaseHelper.instance.queryCart();

      List<dynamic> invoiceData = [];
      int i = 1;
      for (dynamic res in data) {
        double gross = double.parse(res.price) * res.count;
        double net = gross;
        // dynamic category =
        Map<String, dynamic> dim = {
          "category": res.productCat,
          "gross_total": gross,
          "id": res.productId,
          "item_code": res.productCode,
          "net_amount": net,
          "quantity": res.count,
          "s_no": i++,
          "vat_amount": res.tax,
        };
        invoiceData.add(dim);
      }
      map.addAll(payment);
      map['invoice'] = {
        "invoiceProducts": invoiceData,
      };
      print(invoiceData);
      int posId = await getPosdataId();
      String token = await getOfflineData("token");
      String outlet = await getOfflineData("outlet");
      String apiData = await getOfflineData("url");
      print(
        api +
            apiData +
            routes(key: "createorder") +
            outlet +
            "&pos_id=" +
            posId.toString(),
      );

      var body = jsonEncode(map);
      final response = await http.post(
        Uri.parse(
          api +
              apiData +
              routes(key: "createorder") +
              outlet +
              "&pos_id=" +
              posId.toString(),
        ),
        headers: {
          "Authorization": "Token " + token,
          "content-type": "application/json",
          "accept": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        DatabaseHelper.instance.truncateCart();
        Fluttertoast.showToast(msg: "Order Created Successfully");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Order Creation fail");
        return false;
      }
    } else {
      Fluttertoast.showToast(msg: "No Pos session found");
      return false;
    }
  } else {
    await createOrderOffline();
    // Dio dio = Dio();
    Map<String, dynamic> map = {
      "paytype": payType,
      "gross_total": subTotal,
      "net_total": total,
      "totalTax": totalTax,
      "discount": discount,
      "discountedAmount": discountAmount,
      "discountType": discountType,
    };
    Map<String, dynamic> payment = {};
    if (payType == "Cash" || payType == "Cash & card") {
      payment.addAll({
        "cashAmount": double.parse(cashAmount),
      });
    }
    if (payType == "Card" || payType == "Cash & card") {
      payment.addAll({
        "card_number": cardNumber,
        "card_type": cardType,
        "cardAmount": double.parse(cardAmount),
      });
    }
    if (payType == "Delivery company") {
      payment.addAll({
        "card_number": cardNumber,
      });
    }

    List<CartProduct> data = await DatabaseHelper.instance.queryCart();
    print("product code " + data[0].productCode);
    List<dynamic> invoiceData = [];
    int i = 1;
    for (dynamic res in data) {
      double gross = double.parse(res.price) * res.count;
      double net = gross;
      // dynamic category =
      Map<String, dynamic> dim = {
        "category": res.productCat,
        "gross_total": gross,
        "id": res.productId,
        "item_code": res.productCode,
        "net_amount": net,
        "quantity": res.count,
        "s_no": i++,
        "vat_amount": res.tax,
      };
      invoiceData.add(dim);
    }
    map.addAll(payment);

    int check =
        await DatabaseHelper.instance.insertTable(map, "tbl_orderOffline");
    if (check != 0) {
      DatabaseHelper.instance.truncateCart();
      Fluttertoast.showToast(msg: "Order Created Successfully");
      return true;
    }
  }

  // } catch (e) {
  //   print(e.message);
  //   return false;
  // }
  // dynamic response = await dio.post("");
}
