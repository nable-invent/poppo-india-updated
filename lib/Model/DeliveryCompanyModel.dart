import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Model/Url.dart';
// import 'package:poppos/Networking/ModelToDB.dart';
import 'package:poppos/Networking/OfflineData.dart';

const String tableName = "deliverycompany";

class DeliveryCompany {
  final int id;
  final String name;
  final bool isCredit;
  final bool isCash;
  DeliveryCompany({
    this.id,
    this.name,
    this.isCredit,
    this.isCash,
  });
}

Future<List<DeliveryCompany>> getDeliveryCompany() async {
  List<DeliveryCompany> dc = [];
  Dio dio = Dio();
  String outlet = await getOfflineData("outlet");
  String token = await getOfflineData("token");
  // print("i am here");
  String apiData = await getOfflineData("url");
  dynamic response = await dio.get(
    api + apiData + routes(key: "listdeliverycompany") + outlet,
    options: Options(headers: {"Authorization": "Token " + token}),
  );

  // List<Table> column = [];
  // Table id = Table(
  //   columnName: "id",
  //   columnType: checkdataType("int"),
  //   isNull: "NOT NULL",
  // );
  // column.add(id);
  // Table name = Table(
  //   columnName: "name",
  //   columnType: checkdataType("String"),
  //   isNull: "NOT NULL",
  // );
  // column.add(name);
  // Table isCredit = Table(
  //   columnName: "is_credit",
  //   columnType: checkdataType("int"),
  //   isNull: "NOT NULL",
  // );
  // column.add(isCredit);
  // Table isCash = Table(
  //   columnName: "is_cash",
  //   columnType: checkdataType("int"),
  //   isNull: "NOT NULL",
  // );
  // column.add(isCash);
  // Table sync = Table(
  //   columnName: "sync",
  //   columnType: checkdataType("int"),
  //   isNull: "NOT NULL",
  // );
  // column.add(sync);

  // await DatabaseHelper.instance.createTable(tableName, column);
  if (response.statusCode == 200) {
    dynamic data = response.data;

    for (dynamic res in data) {
      DeliveryCompany d = DeliveryCompany(
        id: res['id'],
        name: res['name'],
        // isCredit: res['is_credit'],
        // isCash: res['is_cash'],
      );
      dc.add(d);
    }
  }
  // print(dc);
  return dc;
}

class Driver {
  final int id;
  final String mobileNo;
  final String name;
  final int deliveryCompany;
  Driver({
    this.id,
    this.mobileNo,
    this.name,
    this.deliveryCompany,
  });
}

Future<List<Driver>> getDeriver() async {
  List<Driver> dc = [];
  Dio dio = Dio();
  String outlet = await getOfflineData("outlet");
  String token = await getOfflineData("token");
  String apiData = await getOfflineData("url");
  dynamic response = await dio.get(
    api + apiData + routes(key: "getdriver") + outlet,
    options: Options(headers: {"Authorization": "Token " + token}),
  );
  if (response.statusCode == 200) {
    dynamic data = response.data;
    for (dynamic res in data) {
      Driver d = Driver(
        id: res['id'],
        name: res['name'],
        mobileNo: res['mobile_no'],
        deliveryCompany: res['delivery_company'],
      );
      dc.add(d);
    }
  }
  return dc;
}

addDriver({
  String mobile,
  String name,
  int company,
}) async {
  if (mobile.length == 0) {
    Fluttertoast.showToast(msg: "Enter Valid Mobile No.");
    return false;
  }
  Dio dio = Dio();
  String outlet = await getOfflineData("outlet");
  String token = await getOfflineData("token");
  FormData form = FormData.fromMap({
    "mobile_no": mobile,
    "name": name ?? "",
    "delivery_company": company,
  });

  String apiData = await getOfflineData("url");
  dynamic response = await dio.post(
    api + apiData + routes(key: "managedriver") + outlet,
    data: form,
    options: Options(headers: {
      "Authorization": "Token " + token,
    }),
  );
  if (response.statusCode == 201) {
    Fluttertoast.showToast(msg: "Driver data added");
    return true;
  }
  Fluttertoast.showToast(msg: "Something went wrong");
  return false;
}
