import 'dart:io' show Platform;
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:poppos/Model/Auth.dart';
import 'package:poppos/Networking/Networking.dart';
import 'package:poppos/Networking/OfflineData.dart';
import 'package:poppos/View/ApiPage.dart';
import 'package:poppos/View/Outlat.dart';
import 'package:poppos/View/Pos.dart';
import './Componant/InputField.dart';
import './Utills/Color.dart';
import 'Model/OfflineModel.dart';
import 'Model/Pinlock.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  databaseFactory = databaseFactoryFfi;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/login": (BuildContext context) => LoginPage(),
        "/pos": (BuildContext context) => POSPage(),
        "/outlet": (BuildContext context) => OutletPage(),
        "/key": (BuildContext context) => ApiPage(),
      },
      title: 'Poppos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: LoginPage(),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  checkLogin() async {
    String url = await getOfflineData("url");
    if (url != "") {
      bool isclose = true;
      try {
        if (await checkConnectivity()) {
          String outlet = await getOfflineData("outlet");
          if (outlet != "") {
            String data = await getOfflineData("token");
            if (data != "") {
              print("Token: " + data);
              isclose = await appOffline(outlet);
              if (!isclose) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => LoginPage(),
                  ),
                  ModalRoute.withName('/login'),
                );
                // print("posOpen");
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute<void>(
                //     builder: (BuildContext context) => POSPage(),
                //   ),
                //   ModalRoute.withName('/pos'),
                // );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => LoginPage(),
                  ),
                  ModalRoute.withName('/login'),
                );
              }
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => LoginPage(),
                ),
                ModalRoute.withName('/login'),
              );
            }
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => OutletPage(),
              ),
              ModalRoute.withName('/outlet'),
            );
          }
        } else {
          String outlet = await getOfflineData("outlet");
          if (outlet != "") {
            appOffline(outlet);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => LoginPage(),
              ),
              ModalRoute.withName('/login'),
            );
          }
        }
      } catch (e) {
        // Fluttertoast.showToast(msg: "No pos session found");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => LoginPage(),
          ),
          ModalRoute.withName('/log '),
        );
      }
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ApiPage(),
        ),
        ModalRoute.withName('/key'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Image.asset(
          "assets/splash/poppos.jpg",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  checkLogin() async {
    String data = await getOfflineData("token");
    print(data);
    if (data != "") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => PinLock(),
        ),
        ModalRoute.withName('/pinlock'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // bool potrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double aspect = MediaQuery.of(context).size.aspectRatio;
    return LayoutBuilder(
      builder: (BuildContext conetxt, BoxConstraints constraint) {
        // print(aspect);
        // if (constraint.maxWidth > 600) {
        return Tablet();

        // constraint.maxHeight
      },
      // },
    );
  }
}

class Tablet extends StatefulWidget {
  Tablet({Key key}) : super(key: key);

  @override
  _TabletState createState() => _TabletState();
}

class _TabletState extends State<Tablet> {
  bool isPassword = true;
  bool isLog = true;
  final TextEditingController userCtrl = new TextEditingController();
  final TextEditingController passCtrl = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        // resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
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
                    controller: userCtrl,
                    label: "Username",
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  InputField(
                    controller: passCtrl,
                    label: "Password",
                    isPassword: isPassword,
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
                  if (isLog)
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isLog = false;
                          });
                          if (await checkAuth(userCtrl.text, passCtrl.text)) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) => POSPage(),
                              ),
                              ModalRoute.withName('/pos'),
                            );
                          }
                          setState(() {
                            isLog = true;
                          });
                        },
                        child: Text("Login"),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(success),
                        ),
                      ),
                    ),
                  if (!isLog)
                    Center(
                      child: CircularProgressIndicator(),
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
