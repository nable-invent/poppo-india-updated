// import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poppos/Model/GroupsModel.dart';
import 'package:poppos/Networking/Networking.dart';
import 'package:poppos/Networking/OfflineData.dart';
import 'package:intl/intl.dart';
// import 'CustomerModel.dart';
// import 'Posmodel.dart';
// import 'Posmodel.dart';
import 'ProductsModel.dart';
import 'Url.dart';

Future<bool> appOffline(String id) async {
  bool response = false;
  if (await checkConnectivity()) {
    await getSettings(id);
    // try {
    //   bool isclose = await getPosdataById(id);
    //   if (isclose) {
    //     Fluttertoast.showToast(msg: "No pos session found");
    //     return false;
    //   }
    // } catch (e) {
    //   Fluttertoast.showToast(msg: "No pos session found");
    //   return false;
    // }

    try {
      await addOfflineData("outlet", id);
      await goToOfflineProduct(id);
      await goToOfflineGroup(id);
      response = true;
    } catch (e) {
      print("error" + e.toString());
    }
  } else {
    String openTime = await getOfflineData("opentime");
    String closeTime = await getOfflineData("closetime");
    if (openTime == "" || closeTime == "") {
      Fluttertoast.showToast(msg: "Please check internet connection");
    } else {
      String start = openTime;
      String end = closeTime;
      DateTime now = DateTime.now();
      String fNow = DateFormat('dd-MM-yyyy kk:mm:ss').format(now);
      String date = DateFormat('dd-MM-yyyy').format(now);
      DateTime startDate =
          DateFormat('dd-MM-yyyy kk:mm:ss').parse("$date $start");
      DateTime endDate = DateFormat('dd-MM-yyyy kk:mm:ss').parse("$date $end");
      DateTime current = DateFormat('dd-MM-yyyy kk:mm:ss').parse(fNow);

      if (startDate.isAfter(endDate)) {
        endDate = endDate.add(Duration(days: 1));
      }
      if (current.isAfter(endDate) || current.isBefore(startDate)) {
        Fluttertoast.showToast(msg: "POS session is closed");
      } else {
        response = true;
      }
    }
  }
  return response;
}

getSettings(String byId) async {
  Dio dio = Dio();
  String token = await getOfflineData("token");
  String apiData = await getOfflineData("url");
  Response response = await dio.get(
    api + apiData + routes(key: "settings") + byId,
    options: Options(
      headers: {
        "Authorization": "Token " + token,
      },
    ),
  );
  if (response.statusCode == 200) {
    dynamic data = response.data;
    await addOfflineData(
        "currency", data['outlet']['country']['currency_code']);
    await addOfflineData("outletname", data['outlet']['name']);
    await addOfflineData("outletaddress", data['outlet']['address']);
    await addOfflineData("logo", data['logo']);
    await addOfflineData("opentime", data['default_opening_time']);
    await addOfflineData("closetime", data['default_closing_time']);
    await addOfflineData("footer", data['footer_for_invoice']);
  }
}
