import 'package:dio/dio.dart';
import 'package:poppos/Networking/OfflineData.dart';

import 'Url.dart';

getPosdata() async {
  Dio dio = Dio();
  bool isclosed = true;
  String token = await getOfflineData("token");
  String outlet = await getOfflineData("outlet");
  String apiData = await getOfflineData("url");
  dynamic response = await dio.get(
    api + apiData + routes(key: "possession") + outlet,
    options: Options(
      headers: {
        "Authorization": "Token " + token,
        "content-type": "application/json",
        "accept": "application/json",
      },
    ),
  );
  if (response.statusCode == 200) {
    dynamic data = response.data;
    isclosed = data['is_closed'];
  }
  return isclosed;
}

getPosdataById(String byId) async {
  try {
    Dio dio = Dio();
    bool isclosed = true;
    String token = await getOfflineData("token");
    String apiData = await getOfflineData("url");
    dynamic response = await dio.get(
      api + apiData + routes(key: "possession") + byId,
      options: Options(
        headers: {
          "Authorization": "Token " + token,
        },
      ),
    );
    if (response.statusCode == 200) {
      dynamic data = response.data;
      isclosed = data['is_closed'];
    }
    print(isclosed);
    return isclosed;
  } catch (e) {
    print(e);
    return true;
  }
}

getPosdataId() async {
  Dio dio = Dio();
  int posid = 0;
  String token = await getOfflineData("token");
  String outlet = await getOfflineData("outlet");
  String apiData = await getOfflineData("url");
  dynamic response = await dio.get(
    api + apiData + routes(key: "possession") + outlet,
    options: Options(
      headers: {
        "Authorization": "Token " + token,
      },
    ),
  );
  if (response.statusCode == 200) {
    dynamic data = response.data;
    posid = data['id'];
  }
  return posid;
}
