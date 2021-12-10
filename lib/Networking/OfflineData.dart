import 'package:shared_preferences/shared_preferences.dart';

// Retrive;
Future<String> getOfflineData(key) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString(key) ?? "";
}

Future<bool> addOfflineData(key, data) async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(key, data);
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteOfflineData(key) async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove(key);
    return true;
  } catch (e) {
    return false;
  }
}
