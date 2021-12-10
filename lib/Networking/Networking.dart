import 'dart:io';

Future<bool> checkConnectivity() async {
  bool response = false;
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      response = true;
    }
  } on SocketException catch (_) {
    print('not connected');
  }
  return response;
}
