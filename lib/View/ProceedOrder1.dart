import 'package:flutter/material.dart';
import 'package:poppos/Componant/Buttons.dart';
import 'package:poppos/Componant/DropDown.dart';
import 'package:poppos/Componant/InputField.dart';
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Model/CartProduct.dart';
import 'package:poppos/Model/CustomerModel.dart';
import 'package:poppos/Model/TaxManagement.dart';
import 'package:poppos/Utills/Color.dart';

import 'ProceedOrder2.dart';

class ProceedOrder extends StatefulWidget {
  ProceedOrder({Key key}) : super(key: key);

  @override
  _ProceedOrderState createState() => _ProceedOrderState();
}

class _ProceedOrderState extends State<ProceedOrder> {
  int payType = 1;
  int ordType = 1;
  int disType = 1;
  int cardType = 1;
  final TextEditingController discountCtrl = TextEditingController();
  final TextEditingController cashCtrl = TextEditingController();
  final TextEditingController cardCtrl = TextEditingController();
  final TextEditingController cardNoCtrl = TextEditingController();
  double total = 0;
  double subtotal = 0;
  double discount = 0;
  Customer cust = Customer(
    id: 0,
    mobileNo: "",
    address: "",
    landmark: "",
    name: "",
  );
  @override
  void initState() {
    super.initState();
    getTotal();
  }

  @override
  Widget build(BuildContext context) {
    double width = (MediaQuery.of(context).size.width / 4) - 4;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: grey,
      appBar: AppBar(
        backgroundColor: primary,
      ),
      // primary: false,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Container(
          constraints: BoxConstraints.expand(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SolidButton(
                          color: danger,
                          onPressed: () {},
                          child: Text("Back"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SolidButton(
                          color: danger,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ProceedOrder2(),
                              ),
                            );
                          },
                          child: Text("Cancel payment"),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SolidButton(
                      color: success,
                      onPressed: () {},
                      child:
                          Text("Validate & Pay " + total.toString() + " INR"),
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: width * 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Payment Details"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: light,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Amount to be paid",
                                      style: TextStyle(
                                        color: dark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    total.toString() + " INR",
                                    style:
                                        TextStyle(color: success, fontSize: 64),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Subtotal:  " +
                                              subtotal.toString() +
                                              " INR"),
                                          Text("Total Tax: 19.2 INR"),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                              "Discount: " + discountCtrl.text),
                                          Text("Change remaining: 0.00 INR"),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Select payment type"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: light,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      payType = 1;
                                    });
                                  },
                                  child: ListTile(
                                    selectedTileColor: primary.withOpacity(0.4),
                                    selected: (payType == 1) ? true : false,
                                    leading: Text(
                                      "Cash",
                                      style: TextStyle(
                                        color: dark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      payType = 2;
                                    });
                                  },
                                  child: ListTile(
                                    selectedTileColor: primary.withOpacity(0.4),
                                    selected: (payType == 2) ? true : false,
                                    leading: Text(
                                      "Card",
                                      style: TextStyle(
                                        color: dark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      payType = 3;
                                    });
                                  },
                                  child: ListTile(
                                    selectedTileColor: primary.withOpacity(0.4),
                                    selected: (payType == 3) ? true : false,
                                    leading: Text(
                                      "Cash & Card",
                                      style: TextStyle(
                                        color: dark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      payType = 4;
                                    });
                                  },
                                  child: ListTile(
                                    selectedTileColor: primary.withOpacity(0.4),
                                    selected: (payType == 4) ? true : false,
                                    leading: Text(
                                      "Delivery Company",
                                      style: TextStyle(
                                        color: dark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: light,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            ordType = 1;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: (ordType == 1)
                                                ? primary
                                                : light,
                                            border: Border.all(
                                              color: primary,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12.0,
                                            ),
                                            child: Text(
                                              "DineIn",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: (ordType == 1)
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            ordType = 2;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: (ordType == 2)
                                                ? primary
                                                : light,
                                            border: Border.all(
                                              color: primary,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12.0,
                                            ),
                                            child: Text(
                                              "Delivery",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: (ordType == 2)
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            ordType = 3;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: (ordType == 3)
                                                ? primary
                                                : light,
                                            border: Border.all(
                                              color: primary,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12.0,
                                            ),
                                            child: Text(
                                              "Take away",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: (ordType == 3)
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: dark.withOpacity(0.5),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SidelabelInput(
                                    label: "Discount",
                                    controller: discountCtrl,
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Dis. Type:",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: DropDown(
                                          value: disType,
                                          items: [
                                            DropdownMenuItem(
                                              child: Text("Percentage (%)"),
                                              value: 1,
                                            ),
                                            DropdownMenuItem(
                                              child: Text("Amount"),
                                              value: 2,
                                            ),
                                          ],
                                          onChange: (val) {
                                            setState(() {
                                              disType = val;
                                            });
                                            FocusScope.of(context).unfocus();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  if (payType == 1 || payType == 3)
                                    SidelabelInput(
                                      label: "Cash:",
                                      controller: cashCtrl,
                                    ),
                                  SizedBox(height: 8),
                                  if (payType == 2 || payType == 3)
                                    SidelabelInput(
                                      label: "Card:",
                                      controller: cardCtrl,
                                    ),
                                  SizedBox(height: 8),
                                  if (payType == 2 || payType == 3)
                                    SidelabelInput(
                                      label: "Card NO.",
                                      controller: cardNoCtrl,
                                    ),
                                  SizedBox(height: 8),
                                  if (payType == 2 || payType == 3)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Dis. Type:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: DropDown(
                                            value: cardType,
                                            items: [
                                              DropdownMenuItem(
                                                child: Text("Master"),
                                                value: 1,
                                              ),
                                              DropdownMenuItem(
                                                child: Text("Visa"),
                                                value: 2,
                                              ),
                                            ],
                                            onChange: (val) {
                                              setState(() {
                                                cardType = val;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: dark.withOpacity(0.5),
                        ),
                        Expanded(
                          child: Center(child: Text("")),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  calcDiscount() {
    setState(() {
      if (disType == 1) {
        discount = (total / double.parse(discountCtrl.text)) * 100;
      }
      if (disType == 2) {
        discount = double.parse(discountCtrl.text);
      }
    });
  }

  getTotal() async {
    TaxManagement calc = TaxManagement();
    List<CartProduct> data = await DatabaseHelper.instance.queryCart();
    // print("cart data" + data[0].price);
    setState(() {
      total = calc.getTotal(data);
      subtotal = calc.getSubTotal(data);
    });
  }
}
