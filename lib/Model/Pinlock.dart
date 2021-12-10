import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:poppos/Componant/Buttons.dart';
import 'package:poppos/Componant/InputField.dart';
import 'package:poppos/Networking/OfflineData.dart';
import 'package:poppos/Utills/Color.dart';
import 'package:poppos/View/Pos.dart';

import '../main.dart';
import 'Auth.dart';

class PinLock extends StatefulWidget {
  PinLock({Key key}) : super(key: key);

  @override
  _PinLockState createState() => _PinLockState();
}

class _PinLockState extends State<PinLock> {
  bool flag = false;
  String username = "";
  bool error = false;
  final TextEditingController pass = TextEditingController();
  @override
  void initState() {
    super.initState();
    getName();
  }

  getName() async {
    String data = await getOfflineData("username");
    setState(() {
      username = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    flag = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Container(
                constraints: BoxConstraints.expand(),
                color: primary,
                child: Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        child: LayoutBuilder(
                          builder: (context, BoxConstraints constraint) {
                            double ratio = 5;
                            if (MediaQuery.of(context).orientation ==
                                Orientation.portrait) {
                              ratio = 2.5;
                            }
                            return Container(
                              height: constraint.maxHeight,
                              width: constraint.maxWidth,
                              decoration: BoxDecoration(
                                color: secondary,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.elliptical(
                                    constraint.maxHeight * ratio,
                                    constraint.maxWidth,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        child: Opacity(
                          opacity: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: LayoutBuilder(
                  builder: (context, BoxConstraints constraints) {
                    double size = 24;
                    if (MediaQuery.of(context).orientation ==
                        Orientation.portrait) {
                      size = 18;
                    }
                    return Container(
                      width: MediaQuery.of(context).size.width * .7,
                      decoration: BoxDecoration(
                        color: light,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(50),
                          right: Radius.circular(50),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(50.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(
                                        "Hey $username,",
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: TextButton(
                                        onPressed: () async {
                                          await logout();
                                          Navigator.pop(context);
                                          Navigator.pushAndRemoveUntil<void>(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (BuildContext context) =>
                                                  MyApp(),
                                            ),
                                            ModalRoute.withName('/'),
                                          );
                                        },
                                        child: Text("Logout"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                "Welcome Back Please Enter Your Last Password",
                                style: TextStyle(
                                  fontSize: size,
                                ),
                              ),
                              InputField(
                                controller: pass,
                              ),
                              if (error)
                                Text(
                                  "Please Enter Valid Password",
                                  style: TextStyle(
                                    color: danger,
                                  ),
                                ),
                              SizedBox(
                                height: 4,
                              ),
                              SolidButton(
                                color: primary,
                                onPressed: () async {
                                  setState(() {
                                    error = false;
                                  });

                                  String password =
                                      await getOfflineData("password");
                                  if (password == pass.text) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            POSPage(),
                                      ),
                                      ModalRoute.withName('/pos'),
                                    );
                                  } else {
                                    setState(() {
                                      error = true;
                                    });
                                    error = true;
                                  }
                                },
                                child: Text("Login"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (flag)
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 16,
                  ),
                  child: TextField(
                    controller: pass,
                    decoration: InputDecoration(
                      hintText: "Password",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            8,
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
