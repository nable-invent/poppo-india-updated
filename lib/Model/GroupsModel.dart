// import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Networking/Networking.dart';
import 'package:poppos/Networking/OfflineData.dart';

import 'Url.dart';

class Groups {
  final int groupId;
  final String groupCode;
  final String groupName;
  Groups({
    this.groupId,
    this.groupCode,
    this.groupName,
  });
}

Future<List<Groups>> getGroups({bool mode = true}) async {
  List<Groups> groupList = [];
  if (await checkConnectivity() && mode) {
    Dio dio = Dio();
    dynamic response = await dio.post(api + "groups.json");
    dynamic data = response.data;
    if (response.statusCode == 200) {
      for (dynamic res in data) {
        Groups g = Groups(
          groupId: res['id'],
          groupName: res['name'],
        );
        groupList.add(g);
      }
    }
  } else {
    return getGroupOffline();
  }

  return groupList;
}

Future<List<Groups>> groupsOfflineData(String id) async {
  List<Groups> groupList = [];
  Dio dio = Dio();
  String token = await getOfflineData("token");
  String apiData = await getOfflineData("url");

  dynamic response = await dio.get(
    api + apiData + routes(key: "listgroup") + id,
    options: Options(headers: {
      "Authorization": "Token " + token,
    }),
  );
  dynamic data = response.data;
  if (response.statusCode == 200) {
    for (dynamic res in data) {
      Groups g = Groups(
        groupId: res['id'],
        groupName: res['name'],
      );
      groupList.add(g);
    }
  }

  return groupList;
}

Future<List<Groups>> getGroupOffline() async {
  List<Groups> getData = await DatabaseHelper.instance.queryAllGroups();
  return getData;
}

goToOfflineGroup(String id) async {
  await DatabaseHelper.instance.truncateGroup();
  List<Groups> data = await groupsOfflineData(id);
  for (dynamic res in data) {
    await DatabaseHelper.instance.insertGroup({
      DatabaseHelper.groupId: res.groupId,
      DatabaseHelper.groupName: res.groupName,
    });
  }
}
