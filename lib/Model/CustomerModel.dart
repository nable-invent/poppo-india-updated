import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Model/Url.dart';
import 'package:poppos/Networking/OfflineData.dart';

const String tableName = "customer";

class Customer {
  final int id;
  final String mobileNo;
  final String name;
  final String address;
  final String landmark;
  final int syncData;
  Customer({
    this.id,
    this.mobileNo,
    this.name,
    this.address,
    this.landmark,
    this.syncData,
  });
}

Future<List<Customer>> getCustomer() async {
  List<Customer> c = [];
  Dio dio = Dio();
  String outlet = await getOfflineData("outlet");
  String token = await getOfflineData("token");
  String apiData = await getOfflineData("url");
  dynamic response = await dio.get(
    api + apiData + routes(key: "getcustomer") + outlet,
    options: Options(headers: {
      "Authorization": "Token " + token,
    }),
  );
  if (response.statusCode == 200) {
    dynamic data = response.data;
    // List<Table> column = [];
    // Table id = Table(
    //   columnName: "id",
    //   columnType: checkdataType("int"),
    //   isNull: " NULL",
    // );
    // column.add(id);
    // Table name = Table(
    //   columnName: "name",
    //   columnType: checkdataType("String"),
    //   isNull: " NULL",
    // );
    // column.add(name);
    // Table mobileNo = Table(
    //   columnName: "mobileNo",
    //   columnType: checkdataType("String"),
    //   isNull: " NULL",
    // );
    // column.add(mobileNo);
    // Table address = Table(
    //   columnName: "address",
    //   columnType: checkdataType("String"),
    //   isNull: " NULL",
    // );
    // column.add(address);
    // Table landmark = Table(
    //   columnName: "landmark",
    //   columnType: checkdataType("String"),
    //   isNull: " NULL",
    // );
    // column.add(landmark);
    // Table sync = Table(
    //   columnName: "sync",
    //   columnType: checkdataType("int"),
    //   isNull: "NOT NULL",
    // );
    // column.add(sync);

    // await DatabaseHelper.instance.createTable(tableName, column);
    for (dynamic res in data) {
      Customer d = Customer(
        id: res['id'],
        name: res['name'],
        mobileNo: res['mobile_no'],
        address: res['address'],
        landmark: res['landmark'],
        syncData: 1,
      );
      c.add(d);
    }
  }
  return c;
}

offlineCustomer() async {
  List<Customer> data = await getCustomer();
  DatabaseHelper.instance.truncateTable(tableName);
  for (dynamic res in data) {
    await DatabaseHelper.instance.insertTable(
      {
        "id": res.id,
        "name": res.name,
        "mobileNo": res.mobileNo,
        "address": res.address,
        "landmark": res.landmark,
        "sync": res.syncData,
      },
      tableName,
    );
  }
}

getOfflineCustomer() async {
  List<Map<String, dynamic>> data =
      await DatabaseHelper.instance.queryAllTableData(table: tableName);
  List<Customer> cData = [];
  for (dynamic res in data) {
    Customer c = Customer(
      id: res.id,
      name: res.name,
      mobileNo: res.mobileNo,
      address: res.address,
      landmark: res.landmark,
      syncData: res.syncData,
    );
    cData.add(c);
  }
  return cData;
}

getOnlineCustomer() async {}

addCustomer({
  String mobile,
  String name,
  String address,
  String landmark,
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
    "address": address ?? "",
    "landmark": landmark ?? "",
  });
  String apiData = await getOfflineData("url");
  dynamic response = await dio.post(
    api + apiData + routes(key: "managecustomer") + outlet,
    data: form,
    options: Options(headers: {
      "Authorization": "Token " + token,
    }),
  );
  if (response.statusCode == 201) {
    Fluttertoast.showToast(msg: "Customer data added");
    return true;
  }
  Fluttertoast.showToast(msg: "Something went wrong");
  return false;
}
