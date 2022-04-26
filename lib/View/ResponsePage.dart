import "package:flutter/material.dart";

// import 'package:poppos/Componant/Buttons.dart';
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Model/Auth.dart';
import 'package:poppos/Model/OfflineModel.dart';
import 'package:poppos/Networking/Networking.dart';
import 'package:poppos/Networking/OfflineData.dart';
import 'package:poppos/Utills/Color.dart';

import 'package:poppos/View/Pos.dart';
import 'package:poppos/View/singleOrderPage.dart';

import '../main.dart';

class ResponsePage extends StatelessWidget {
  final bool successFlag;
  const ResponsePage({
    Key key,
    this.successFlag = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Order Response"),
            backgroundColor: primary,
            actions: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () async {
                        await logout();
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => MyApp(),
                          ),
                          ModalRoute.withName('/'),
                        );
                      },
                      child: Text(
                        "Logout",
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () async {
                        await DatabaseHelper.instance.truncateCart();
                        String outlet = await getOfflineData("outlet");
                        await appOffline(outlet);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Sync Data",
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ],
              )
              // Builder(
              //   builder: (context) => IconButton(
              //     icon: Icon(
              //       Icons.add_shopping_cart_outlined,
              //       size: 36,
              //     ),
              //     onPressed: () => Scaffold.of(context).openEndDrawer(),
              //     tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              //   ),
              // ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: (successFlag) ? SuccessPage() : FailPage(),
            ),
          ),
        ),
      ),
    );
  }
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            title: Text(
              "Order Placed",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: success,
              ),
            ),
            subtitle: Text(
              "Thank for order in poppos",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                // fontWeight: FontWeight.bold,
                color: dark.withOpacity(0.8),
              ),
            ),
          ),
          Icon(
            Icons.check_circle_outline,
            size: 200,
            color: success,
          ),
          ElevatedButton(
            onPressed: () async {
              bool check = await checkConnectivity();
              if (check) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SingleOrderPage(),
                    ));
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => POSPage(),
                  ),
                  ModalRoute.withName("/pos"),
                );
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(success),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16,
              ),
              child: Text(
                "Continue",
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FailPage extends StatelessWidget {
  const FailPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            title: Text(
              "Something went wrong",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: danger,
              ),
            ),
            subtitle: Text(
              "Please try again",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                // fontWeight: FontWeight.bold,
                color: dark.withOpacity(0.8),
              ),
            ),
          ),
          Icon(
            Icons.highlight_off_outlined,
            size: 200,
            color: danger,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(danger),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16,
              ),
              child: Text(
                "Try again",
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
