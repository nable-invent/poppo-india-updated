import 'package:dio/dio.dart';
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Networking/ModelToDB.dart';
import 'package:poppos/Networking/Networking.dart';
import 'package:poppos/Networking/OfflineData.dart';

import 'Url.dart';

class Outlets {
  final String id;
  final String name;
  final String address;
  Outlets({
    this.id,
    this.name,
    this.address,
  });
}

Future<List<Outlets>> getOutlet() async {
  List<Outlets> outlets = [];
  if (await checkConnectivity()) {
    Dio dio = Dio();
    // String token = await getOfflineData("token");
    // print(token);

    try {
      await createOutlet();
      String key = await getOfflineData("key");
      String apiData = await getOfflineData("url");
      print(api + apiData + routes(key: "outlets") + key);
      dynamic response = await dio.get(
        api + apiData + routes(key: "outlets") + key,
        // options: Options(headers: {
        //   "Authorization": "Token " + token,
        // }),
      );
      if (response.statusCode == 200) {
        dynamic data = response.data;
        for (dynamic res in data) {
          Outlets o = Outlets(
            id: res['id'].toString(),
            name: res['name'],
            address: res['address'],
          );
          await DatabaseHelper.instance.insertTable(
            {
              "id": res['id'].toString(),
              "name": res['name'],
              "address": res['address'],
            },
            "tbl_outlet",
          );
          outlets.add(o);
        }
      }
    } catch (e, stack) {
      print("e.response");
      print(stack);
    }
  } else {
    return await getOutletOffline();
  }
  return outlets;
}

createOutlet() async {
  List<Table> column = [];
  Table id = Table(
    columnName: "id",
    columnType: checkdataType("int"),
    isNull: " NULL",
  );
  column.add(id);
  Table name = Table(
    columnName: "name",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(name);
  Table address = Table(
    columnName: "address",
    columnType: checkdataType("String"),
    isNull: " NULL",
  );
  column.add(address);

  await DatabaseHelper.instance.createTable("tbl_outlet", column);
}

Future<List<Outlets>> getOutletOffline() async {
  List<Outlets> orderList = [];
  // try {
  List<Map<String, dynamic>> order =
      await DatabaseHelper.instance.queryAllTableData(table: "tbl_outlet");
  // print(order);
  for (dynamic res in order) {
    Outlets ord = Outlets(
      id: res['id'].toString(),
      name: res['name'],
      address: res['address'],
    );
    orderList.add(ord);
  }
  // } catch (e) {
  //   print(e.error);
  // }

  return orderList;
}
