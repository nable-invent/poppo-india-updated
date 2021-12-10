import 'package:flutter/material.dart';
import 'package:poppos/Componant/Buttons.dart';
import 'package:poppos/Componant/InputField.dart' as input;
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Model/Auth.dart';
import 'package:poppos/Model/CustomerModel.dart';
import 'package:poppos/Model/OfflineModel.dart';
import 'package:poppos/Networking/OfflineData.dart';
import 'package:poppos/Utills/Color.dart';
import 'package:poppos/View/ProceedOrder.dart';

import '../main.dart';

class CreateCustomer extends StatefulWidget {
  final String mobile;
  final String name;
  final String address;
  final String landmark;
  CreateCustomer({
    Key key,
    this.mobile = "",
    this.name = "",
    this.address = "",
    this.landmark = "",
  }) : super(key: key);

  @override
  _CreateCustomerState createState() => _CreateCustomerState();
}

class _CreateCustomerState extends State<CreateCustomer> {
  final TextEditingController mobile = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController landmark = TextEditingController();
  @override
  Widget build(BuildContext context) {
    mobile.text = widget.mobile;
    name.text = widget.name;
    address.text = widget.address;
    landmark.text = widget.landmark;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Create Customer",
          ),
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

                      // await logout();

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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create Customer",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                input.InputField(
                  label: "Mobile No.",
                  controller: mobile,
                ),
                SizedBox(
                  height: 12,
                ),
                input.InputField(
                  label: "Customer Name",
                  controller: name,
                ),
                SizedBox(
                  height: 12,
                ),
                input.InputField(
                  label: "Address",
                  controller: address,
                ),
                SizedBox(
                  height: 12,
                ),
                input.InputField(
                  label: "Land Mark",
                  controller: landmark,
                ),
                SizedBox(
                  height: 12,
                ),
                SolidButton(
                  onPressed: () async {
                    bool flag = await addCustomer(
                      mobile: mobile.text,
                      name: name.text,
                      address: address.text,
                      landmark: landmark.text,
                    );
                    if (flag) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ProceedOrder(),
                        ),
                      );
                    }
                  },
                  color: primary,
                  child: Text("Add"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
