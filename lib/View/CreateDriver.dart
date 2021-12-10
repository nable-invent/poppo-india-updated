// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:poppos/Componant/Buttons.dart';
import 'package:poppos/Componant/DropDown.dart';
import 'package:poppos/Componant/InputField.dart' as input;
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Model/Auth.dart';
import 'package:poppos/Model/DeliveryCompanyModel.dart';
import 'package:poppos/Model/OfflineModel.dart';
import 'package:poppos/Networking/OfflineData.dart';
import 'package:poppos/Utills/Color.dart';

import '../main.dart';
import 'ProceedOrder.dart';

class CreateDriver extends StatefulWidget {
  final String mobile;
  final String name;
  final int company;
  CreateDriver({
    Key key,
    this.mobile = "",
    this.name = "",
    this.company,
  }) : super(key: key);

  @override
  _CreateDriverState createState() => _CreateDriverState();
}

class _CreateDriverState extends State<CreateDriver> {
  final TextEditingController mobile = TextEditingController();
  final TextEditingController name = TextEditingController();
  int value = 0;
  @override
  void initState() {
    super.initState();
    value = widget.company;
  }

  @override
  Widget build(BuildContext context) {
    mobile.text = widget.mobile;
    name.text = widget.name;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Create Driver",
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
                  "Create Driver",
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
                  label: "Driver Name",
                  controller: name,
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "Delivery Company",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                FutureBuilder(
                  future: getDeliveryCompany(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      List<DeliveryCompany> data = snapshot.data;
                      if (data.length > 0) {
                        return DropdownButtonHideUnderline(
                          child: DropDown(
                            value: (value != 0) ? value : data[0].id,
                            onChange: (val) {
                              setState(() {
                                value = val;
                              });
                            },
                            items: data.map<DropdownMenuItem>((e) {
                              return DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              );
                            }).toList(),
                          ),
                        );
                      } else {
                        return Text("No Company found");
                      }
                    } else {
                      return Text("Please Wait");
                    }
                  },
                ),
                SizedBox(height: 12),
                SolidButton(
                  onPressed: () async {
                    bool flag = await addDriver(
                      mobile: mobile.text,
                      name: name.text,
                      company: value,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
