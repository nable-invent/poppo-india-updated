import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poppos/Networking/OfflineData.dart';
import 'package:poppos/View/Outlat.dart';
import 'package:poppos/main.dart';
import '../Componant/InputField.dart';
import '../Utills/Color.dart';

class ApiPage extends StatefulWidget {
  const ApiPage({Key key}) : super(key: key);

  @override
  _ApiPageState createState() => _ApiPageState();
}

class _ApiPageState extends State<ApiPage> {
  bool isPassword = true;
  final TextEditingController apiCtrl = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  validateKey() async {
    try {
      Dio dio = new Dio();
      FormData form = FormData.fromMap({
        "key": apiCtrl.text,
      });
      dynamic response = await dio.post(
        "https://poppos.io/clients/api/url/",
        // "http://poppos.local:8000/clients/api/url/",

        data: form,
      );
      if (response.statusCode == 200) {
        dynamic data = response.data;
        String name = data['name'];
        String url = data['url'];
        String key = apiCtrl.text;
        await addOfflineData("name", name);
        await addOfflineData("url", url);
        await addOfflineData("key", key);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => OutletPage(),
          ),
        );
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "Invalid key");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(height: 500),
                  Center(child: Image.asset("assets/images/1.jpg")),

                  SizedBox(
                    height: 24,
                  ),
                  InputField(
                    controller: apiCtrl,
                    label: "Company Code",
                  ),

                  SizedBox(
                    height: 16,
                  ),
                  // TextButton(
                  //   onPressed: () {
                  //     setState(() {
                  //       isPassword = !isPassword;
                  //     });
                  //   },
                  //   child: Text(
                  //     (isPassword) ? "Show Password" : "Hide Password",
                  //   ),
                  // ),
                  SizedBox(
                    height: 16,
                  ),

                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: validateKey,
                      child: Text("Verify"),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(success),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Center(
                    child: Text(
                      "Powered by Nable Invent Solutions",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TabletCode extends StatefulWidget {
  TabletCode({Key key}) : super(key: key);

  @override
  _TabletCodeState createState() => _TabletCodeState();
}

class _TabletCodeState extends State<TabletCode> {
  bool isPassword = true;
  final TextEditingController apiCtrl = new TextEditingController();
  validateKey() async {
    try {
      Dio dio = new Dio();
      FormData form = FormData.fromMap({
        "key": apiCtrl.text,
      });
      dynamic response = await dio.post(
        "https://poppos.io/clients/api/url/",
        // "http://poppos.local:8000/clients/api/url/",

        data: form,
      );
      if (response.statusCode == 200) {
        dynamic data = response.data;
        String name = data['name'];
        String url = data['url'];
        addOfflineData("name", name);
        addOfflineData("url", url);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginPage(),
          ),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid key");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(height: 500),
                  Center(child: Image.asset("assets/images/1.jpg")),

                  SizedBox(
                    height: 24,
                  ),
                  InputField(
                    controller: apiCtrl,
                    label: "Company Code",
                  ),

                  SizedBox(
                    height: 16,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isPassword = !isPassword;
                      });
                    },
                    child: Text(
                      (isPassword) ? "Show Password" : "Hide Password",
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),

                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: validateKey,
                      child: Text("Verify"),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(success),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Center(
                    child: Text(
                      "Powered by Nable Invent Solutions",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
