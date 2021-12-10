import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Networking/Networking.dart';
import '../Networking/OfflineData.dart';
// import 'package:flutter/material.dart';

import 'OfflineModel.dart';
import 'Url.dart';

checkAuth(String username, String password) async {
  bool auth = false;
  if (!(await checkConnectivity())) {
    Fluttertoast.showToast(msg: "Please Check Internet Connection");
    return auth;
  }

  if (username.length == 0) {
    Fluttertoast.showToast(msg: "Enter valid username");
    return false;
  } else if (password.length == 0) {
    Fluttertoast.showToast(msg: "Enter valid password");
    return false;
  }
  try {
    Dio dio = new Dio();
    FormData form = FormData.fromMap({
      "username": username,
      "password": password,
    });
    String apiData = await getOfflineData("url");
    // print(api + apiData + routes(key: "auth"));
    String key = await getOfflineData("key");
    Response res = await dio.get(
      api + apiData + routes(key: "outlets") + key,
    );
    String outlet = await getOfflineData("outlet");
    if (res.statusCode == 200) {
      bool flag = true;
      for (dynamic r in res.data) {
        if (r['id'].toString() == outlet) {
          for (dynamic user in r['working_employees']) {
            if (user == username) {
              flag = false;
            }
          }
        }
      }
      if (flag) {
        Fluttertoast.showToast(msg: "Invalid credentials");
        return false;
      }
    }
    dynamic response = await dio.post(
      api + apiData + routes(key: "auth"),
      data: form,
    );
    if (response.statusCode == 200) {
      dynamic data = response.data;
      String token = data['token'];
      await addOfflineData("token", token);
      auth = true;
      await appOffline(outlet);
      await addOfflineData("username", username);
      await addOfflineData("password", password);
    }
    // DateTime now = new DateTime.now();
    // await addOfflineData("date", now.toString());
  } catch (e) {
    if (e == null) {
      return;
    }
    if (e.response.statusCode == 403) {
      Fluttertoast.showToast(msg: "User is logged in from another device");
    } else if (e.response.statusCode == 400) {
      Fluttertoast.showToast(msg: "Invalid credentials");
    } else {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  return auth;
}

logout() async {
  bool flag = false;
  if (await checkConnectivity()) {
    String token = await getOfflineData("token");
    Dio dio = Dio();
    FormData form = FormData.fromMap({
      "token": token,
    });
    try {
      String apiData = await getOfflineData("url");
      dynamic response = await dio.post(
        api + apiData + routes(key: "logout"),
        data: form,
      );
      if (response.statusCode == 200) {
        String dim = await getOfflineData("token");
        print("token $dim");
        await deleteOfflineData("token");
        // await deleteOfflineData("outlet");
        await deleteOfflineData("username");
        await deleteOfflineData("password");
        DatabaseHelper.instance.truncateCart();
      }
    } catch (e) {
      print(e.response);
      return false;
    }
  } else {
    Fluttertoast.showToast(msg: "Please Check Internet Connection");
  }

  return flag;
}
