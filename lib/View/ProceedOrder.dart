import 'package:flutter/material.dart';
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Model/Auth.dart';
import 'package:poppos/Model/CartProduct.dart';
import 'package:poppos/Model/CustomerModel.dart';
import 'package:poppos/Model/DeliveryCompanyModel.dart';
import 'package:poppos/Model/OfflineModel.dart';
import 'package:poppos/Model/OrderModel.dart';
// import 'package:poppos/Model/Posmodel.dart';
import 'package:poppos/Model/TaxManagement.dart';
import 'package:poppos/Networking/OfflineData.dart';
// import 'package:poppos/Model/DeliveryCompanyModel.dart';
import 'package:poppos/Utills/Color.dart';
import 'package:poppos/View/CreateCustomer.dart';
import 'package:poppos/View/CreateDriver.dart';
import 'package:poppos/View/Pos.dart';
import 'package:poppos/View/ResponsePage.dart';

import '../main.dart';

class ProceedOrder extends StatefulWidget {
  ProceedOrder({Key key}) : super(key: key);

  @override
  _ProceedOrderState createState() => _ProceedOrderState();
}

class _ProceedOrderState extends State<ProceedOrder> {
  final TextEditingController contact = TextEditingController();
  final TextEditingController delivery = TextEditingController();
  final TextEditingController discount = TextEditingController();
  final TextEditingController cash = TextEditingController();
  final TextEditingController card = TextEditingController();
  final TextEditingController cardNo = TextEditingController();
  bool cardErrorFlag = false;
  int customerId = 0;
  int deriverId = 0;
  int paymentType = 1;
  int invoiceType = 1;
  double change = 0;
  double discountAmount = 0;
  List<String> disType = [
    "Discount %",
    "Discount AED",
  ];
  double cardAmount = 0;
  double cashAmount = 0;
  List<String> cardType = [
    "Master",
    "Visa",
  ];
  List<DeliveryCompany> deliveryComp = [];
  int disValue = 0;
  int cardValue = 0;
  int deliveryValue = 0;
  changeDis(int val) {
    setState(() {
      disValue = val;
    });
  }

  changeCard(int val) {
    setState(() {
      cardValue = val;
    });
  }

  changeDelivery(int val) {
    setState(() {
      deliveryValue = val;
    });
  }

  getCustData() async {
    List<Customer> data = await getCustomer();
    if (mounted) {
      setState(() {
        cust = data;
      });
    }
  }

  List<Driver> driver = [];
  getDeliveryData() async {
    List<Driver> data = await getDeriver();
    if (mounted) {
      setState(() {
        driver = data;
      });
    }
  }

  getDeliveryCompanyData() async {
    List<DeliveryCompany> data = await getDeliveryCompany();
    if (mounted) {
      setState(() {
        deliveryComp = data;
      });
    }
  }

  List<Customer> cust = [];
  List<CartProduct> cartProduct = [];
  double total = 0;
  double subtotal = 0;
  double taxAmount = 0;
  getCartProduct() async {
    TaxManagement tax = TaxManagement();
    List<CartProduct> data = await DatabaseHelper.instance.queryCart();
    // print("product code " + data[0].productCat);
    if (mounted) {
      setState(() {
        cartProduct = data;
        subtotal = tax.getSubTotal(data);
        total = tax.getTotal(data);
        taxAmount = tax.getTotalTax(data);
      });
    }
  }

  manageTotalData({String discount}) async {
    // double totalData = 0;
    double discountData = 0;
    try {
      discountData = double.parse(discount);
    } catch (e) {
      discountData = 0;
    }

    TaxManagement tax = TaxManagement();
    List<CartProduct> data = await DatabaseHelper.instance.queryCart();
    // print("product code " + data[0].productCat);
    if (mounted) {
      setState(() {
        cartProduct = data;
        total = tax.getTotalWithDiscount(data, discountData, disValue);
        cash.text = total.toStringAsFixed(2);
        taxAmount = tax.getTotalTaxWithDiscount(data, discountData, disValue);
        discountAmount = tax.getDiscount(data, discountData, disValue);
        if (double.parse(cash.text) > total) {
          change = total - double.parse(cash.text);
        } else {
          change = 0;
        }
      });
    }
    // return totalData;
  }

  @override
  void initState() {
    super.initState();
    discount.text = "0";

    if (mounted) {
      getCustData();
      getDeliveryData();
      getCartProduct();
      manageTotalData(discount: "0");
      cardAmount = 0;
      // cash.text = total.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        switch (paymentType) {
          case 1:
            if (double.parse(cash.text) < total) {
              cash.text = total.toString();
            }
            break;
          case 3:
            setState(() {
              cardAmount = total - double.parse(cash.text);
            });
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => POSPage(),
          ),
          ModalRoute.withName("/pos"),
        );
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: light.withOpacity(0.8),
          appBar: AppBar(
            title: Text(
              "POPPOS",
              style: TextStyle(
                fontSize: 32,
              ),
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
          body: OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) {
              if (orientation == Orientation.portrait) {
                return Portrait();
              } else if (orientation == Orientation.landscape) {
                return Landscape();
              } else {
                return Portrait();
              }
            },
          ),
        ),
      ),
    );
  }
}

class Landscape extends StatefulWidget {
  Landscape({Key key}) : super(key: key);

  @override
  _LandscapeState createState() => _LandscapeState();
}

class _LandscapeState extends State<Landscape> {
  final TextEditingController contact = TextEditingController();
  final TextEditingController delivery = TextEditingController();
  final TextEditingController discount = TextEditingController();
  final TextEditingController cash = TextEditingController();
  final TextEditingController card = TextEditingController();
  final TextEditingController cardNo = TextEditingController();
  bool cardErrorFlag = false;
  int customerId = 0;
  int deriverId = 0;
  int paymentType = 1;
  int invoiceType = 1;
  double change = 0;
  double discountAmount = 0;
  List<String> disType = [
    "Discount %",
    "Discount AED",
  ];
  double cardAmount = 0;
  double cashAmount = 0;
  List<String> cardType = [
    "Master",
    "Visa",
  ];
  List<DeliveryCompany> deliveryComp = [];
  int disValue = 0;
  int cardValue = 0;
  int deliveryValue = 0;
  changeDis(int val) {
    setState(() {
      disValue = val;
    });
  }

  changeCard(int val) {
    setState(() {
      cardValue = val;
    });
  }

  changeDelivery(int val) {
    setState(() {
      deliveryValue = val;
    });
  }

  getCustData() async {
    List<Customer> data = await getCustomer();
    if (mounted) {
      setState(() {
        cust = data;
      });
    }
  }

  List<Driver> driver = [];
  getDeliveryData() async {
    List<Driver> data = await getDeriver();
    if (mounted) {
      setState(() {
        driver = data;
      });
    }
  }

  getDeliveryCompanyData() async {
    List<DeliveryCompany> data = await getDeliveryCompany();
    if (mounted) {
      setState(() {
        deliveryComp = data;
      });
    }
  }

  List<Customer> cust = [];
  List<CartProduct> cartProduct = [];
  double total = 0;
  double subtotal = 0;
  double taxAmount = 0;
  getCartProduct() async {
    TaxManagement tax = TaxManagement();
    List<CartProduct> data = await DatabaseHelper.instance.queryCart();
    // print("product code " + data[0].productCat);
    if (mounted) {
      setState(() {
        cartProduct = data;
        subtotal = tax.getSubTotal(data);
        total = tax.getTotal(data);
        taxAmount = tax.getTotalTax(data);
      });
    }
  }

  manageTotalData({String discount}) async {
    // double totalData = 0;
    double discountData = 0;
    try {
      discountData = double.parse(discount);
    } catch (e) {
      discountData = 0;
    }

    TaxManagement tax = TaxManagement();
    List<CartProduct> data = await DatabaseHelper.instance.queryCart();
    // print("product code " + data[0].productCat);
    if (mounted) {
      setState(() {
        cartProduct = data;
        total = tax.getTotalWithDiscount(data, discountData, disValue);
        cash.text = total.toStringAsFixed(2);
        taxAmount = tax.getTotalTaxWithDiscount(data, discountData, disValue);
        discountAmount = tax.getDiscount(data, discountData, disValue);
        if (double.parse(cash.text) > total) {
          change = total - double.parse(cash.text);
        } else {
          change = 0;
        }
      });
    }
    // return totalData;
  }

  @override
  void initState() {
    super.initState();
    discount.text = "0";

    if (mounted) {
      getCustData();
      getDeliveryData();
      getCartProduct();
      manageTotalData(discount: "0");
      cardAmount = 0;
      // cash.text = total.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 8;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              Container(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(secondary),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => POSPage(),
                        ),
                        ModalRoute.withName("/pos"),
                      );
                      // Navigator.pop(context);
                    },
                    child: Text("Back"),
                  ),
                ),
              ),
              Container(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(secondary),
                    ),
                    onPressed: () async {
                      await DatabaseHelper.instance.truncateCart();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => POSPage(),
                        ),
                        ModalRoute.withName("/pos"),
                      );
                    },
                    child: Text("cancel"),
                  ),
                ),
              ),
              Container(
                // color: dark,
                width: width * 6,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(success),
                      ),
                      onPressed: () async {
                        String payType = "";
                        switch (paymentType) {
                          case 1:
                            payType = "Cash";
                            break;
                          case 2:
                            payType = "Card";
                            break;
                          case 3:
                            payType = "Cash & card";
                            break;
                          case 4:
                            payType = "Delivery company";
                            break;
                          default:
                            break;
                        }
                        String card = (cardValue == 1) ? "Master" : "Visa";
                        String discountType = (disValue == 0)
                            ? "DISCOUNT_BY_PERCENTAGE"
                            : "DISCOUNT_BY_AMOUNT";
                        switch (paymentType) {
                          case 1:
                            if (double.parse(cash.text) < total) {
                              cash.text = total.toString();
                            }
                            break;
                          case 2:
                            if (cardNo.text.length == 0) {
                              setState(() {
                                cardErrorFlag = true;
                              });
                            } else {
                              setState(() {
                                cardErrorFlag = false;
                              });
                            }
                            break;
                          case 3:
                            setState(() {
                              cardAmount = total - double.parse(cash.text);
                            });
                            if (cardNo.text.length == 0) {
                              setState(() {
                                cardErrorFlag = true;
                              });
                            } else {
                              setState(() {
                                cardErrorFlag = false;
                              });
                            }
                            break;
                        }
                        if (cardErrorFlag) {
                          return;
                        }
                        bool data = await placeOrder(
                          payType: payType,
                          cardType: card,
                          cardNumber: cardNo.text,
                          cardAmount: cardAmount.toString(),
                          cashAmount: cash.text,
                          customerId: customerId,
                          discount: double.parse(discount.text),
                          discountAmount: discountAmount,
                          discountType: discountType,
                          driverId: deriverId,
                          subTotal: subtotal,
                          total: total,
                          totalTax: taxAmount,
                          // context: context,
                        );
                        if (data) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => ResponsePage(
                                successFlag: true,
                              ),
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => ResponsePage(
                                successFlag: false,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Validate And Pay " + total.toStringAsFixed(2) + " AED",
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                Container(
                  width: width * 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Payment Details"),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        color: light,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Amount To be paid ",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                total.toStringAsFixed(2) + " AED",
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: success,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Subtotal: ",
                                        style: TextStyle(
                                          color: dark.withOpacity(0.5),
                                        ),
                                      ),
                                      Text(
                                        subtotal.toString() + " AED",
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Discount: ",
                                        style: TextStyle(
                                          color: dark.withOpacity(0.5),
                                        ),
                                      ),
                                      Text(
                                        discount.text +
                                            ((disValue == 0) ? "%" : "AED"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Total tax: ",
                                        style: TextStyle(
                                          color: dark.withOpacity(0.5),
                                        ),
                                      ),
                                      Text((taxAmount.toStringAsFixed(2)) +
                                          " AED"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Change remaining: ",
                                        style: TextStyle(
                                          color: dark.withOpacity(0.5),
                                        ),
                                      ),
                                      Text(change.toString() + " AED"),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: width * 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select payment type'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          color: light,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    paymentType = 1;
                                  });
                                },
                                child: Container(
                                  color: (paymentType == 1)
                                      ? primary.withOpacity(0.2)
                                      : light.withOpacity(0.1),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text("Cash"),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    paymentType = 2;
                                    change = 0;
                                    card.text = total.toString();
                                  });
                                },
                                child: Container(
                                  color: (paymentType == 2)
                                      ? primary.withOpacity(0.2)
                                      : light.withOpacity(0.1),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text("Card"),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(
                                    () {
                                      paymentType = 3;
                                      if (double.parse(cash.text) > total) {
                                        cash.text = total.toString();
                                        card.text =
                                            (total - double.parse(cash.text))
                                                .toString();
                                      }

                                      change = 0;
                                    },
                                  );
                                },
                                child: Container(
                                  color: (paymentType == 3)
                                      ? primary.withOpacity(0.2)
                                      : light.withOpacity(0.1),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text("Cash & card"),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    paymentType = 4;
                                    change = 0;
                                  });
                                },
                                child: Container(
                                  color: (paymentType == 4)
                                      ? primary.withOpacity(0.2)
                                      : light.withOpacity(0.1),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text("Delivery company"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              color: light,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: width * 2,
                      // color: dark,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  invoiceType = 1;
                                });
                              },
                              child: Container(
                                height: 64,
                                decoration: BoxDecoration(
                                  color: (invoiceType == 1)
                                      ? dark
                                      : light.withOpacity(0.1),
                                  border: Border.all(
                                    color: dark,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Dine in",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (invoiceType == 1) ? light : dark,
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
                                  invoiceType = 2;
                                });
                              },
                              child: Container(
                                height: 64,
                                decoration: BoxDecoration(
                                  color: (invoiceType == 2)
                                      ? dark
                                      : light.withOpacity(0.1),
                                  border: Border.all(
                                    color: dark,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Delivery",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (invoiceType == 2) ? light : dark,
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
                                  invoiceType = 3;
                                });
                              },
                              child: Container(
                                height: 64,
                                decoration: BoxDecoration(
                                  color: (invoiceType == 3)
                                      ? dark
                                      : light.withOpacity(0.1),
                                  border: Border.all(
                                    color: dark,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Take away",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (invoiceType == 3) ? light : dark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: width * 2,
                      // color: dark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InputField(
                            onChange: (val) {
                              manageTotalData(discount: val);
                            },
                            tag: "Discount:",
                            controller: discount,
                            padding: EdgeInsets.symmetric(
                              vertical: 0.8,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          CustomDropdown(
                            tag: "Distype Type",
                            item: disType,
                            value: disValue,
                            padding: EdgeInsets.symmetric(
                              vertical: 0.8,
                            ),
                            onTap: () {
                              manageTotalData(discount: discount.text);
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            onChange: changeDis,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          if (paymentType == 1 || paymentType == 3)
                            InputField(
                              onChange: (val) {
                                switch (paymentType) {
                                  case 1:
                                    if (double.parse(cash.text) < total) {
                                      cash.text = total.toString();
                                    } else {
                                      setState(() {
                                        change =
                                            double.parse(cash.text) - total;
                                      });
                                    }
                                    break;
                                  case 3:
                                    if (double.parse(cash.text) > total) {
                                      cash.text = total.toString();
                                    }
                                    setState(() {
                                      card.text =
                                          (total - double.parse(cash.text))
                                              .toString();
                                    });

                                    break;
                                }
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                              },
                              tag: "Cash:",
                              controller: cash,
                              padding: EdgeInsets.symmetric(
                                vertical: 0.8,
                              ),
                            ),
                          SizedBox(
                            height: 8,
                          ),
                          if (paymentType == 2 || paymentType == 3)
                            InputField(
                              tag: "Card:",
                              enable: false,
                              controller: card,
                              padding: EdgeInsets.symmetric(
                                vertical: 0.8,
                              ),
                            ),
                          SizedBox(
                            height: 8,
                          ),
                          if (paymentType != 1)
                            InputField(
                              tag: "Card No.:",
                              controller: cardNo,
                              padding: EdgeInsets.symmetric(
                                vertical: 0.8,
                              ),
                              onChange: (val) {
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                              },
                            ),
                          if (cardErrorFlag)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                "Please enter card no",
                                textAlign: TextAlign.start,
                                style: TextStyle(color: danger),
                              ),
                            ),
                          SizedBox(
                            height: 8,
                          ),
                          if (paymentType == 2 || paymentType == 3)
                            CustomDropdown(
                              tag: "Card Type",
                              item: cardType,
                              value: cardValue,
                              onChange: changeCard,
                              padding: EdgeInsets.symmetric(
                                vertical: 0.8,
                              ),
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              },
                            ),
                          SizedBox(
                            height: 8,
                          ),
                          if (paymentType == 4)
                            FutureBuilder(
                                future: getDeliveryCompany(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text("error"),
                                    );
                                  }
                                  // print(snapshot.data.length);
                                  if (snapshot.hasData) {
                                    List<DeliveryCompany> data = snapshot.data;

                                    if (data.length > 0) {
                                      if (deliveryValue == 0) {
                                        deliveryValue = data[0].id;
                                      }
                                      return DynamicDropdown(
                                        tag: "Delivery Company",
                                        item: data,
                                        value: deliveryValue,
                                        onChange: changeDelivery,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 0.8,
                                        ),
                                        onTap: () {
                                          FocusScope.of(context).requestFocus(
                                            FocusNode(),
                                          );
                                        },
                                      );
                                    } else {
                                      return Center(
                                        child:
                                            Text("No Delivery Company found"),
                                      );
                                    }
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: primary,
                                        color: secondary,
                                      ),
                                    );
                                  }
                                }),
                          SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                    ),
                    if (invoiceType != 2)
                      Container(
                        width: width * 2,
                        child: Opacity(
                          opacity: 0,
                        ),
                      ),
                    if (invoiceType == 2)
                      Container(
                        width: width * 2,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InputField(
                                tag: "Contact No:",
                                controller: contact,
                                padding: EdgeInsets.symmetric(
                                  vertical: 0.8,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              FutureBuilder(
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (cust
                                          .where((i) =>
                                              (i.mobileNo == contact.text))
                                          .toList()
                                          .length >
                                      0) {
                                    Customer cData = cust
                                        .where(
                                            (i) => (i.mobileNo == contact.text))
                                        .toList()[0];
                                    return ListTile(
                                      title: Text("Name: " + cData.name),
                                      subtitle: Text(
                                        "Address: " +
                                            cData.address +
                                            "\n Landmark: " +
                                            cData.landmark,
                                      ),
                                      isThreeLine: true,
                                    );
                                  } else {
                                    return Opacity(opacity: 0);
                                  }
                                },
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              if (cust
                                      .where(
                                          (i) => (i.mobileNo == contact.text))
                                      .toList()
                                      .length ==
                                  0)
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      dark,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            CreateCustomer(
                                          mobile: contact.text,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Add Customer",
                                  ),
                                ),
                              if (cust
                                      .where(
                                          (i) => (i.mobileNo == contact.text))
                                      .toList()
                                      .length >
                                  0)
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      dark,
                                    ),
                                  ),
                                  onPressed: () {
                                    Customer cData = cust
                                        .where(
                                            (i) => (i.mobileNo == contact.text))
                                        .toList()[0];
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            CreateCustomer(
                                          mobile: cData.mobileNo,
                                          name: cData.name,
                                          address: cData.address,
                                          landmark: cData.landmark,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Update Customer",
                                  ),
                                ),
                              SizedBox(
                                height: 8,
                              ),
                              InputField(
                                tag: "Driver No:",
                                controller: delivery,
                                padding: EdgeInsets.symmetric(
                                  vertical: 0.8,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              FutureBuilder(
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (driver
                                          .where((i) =>
                                              (i.mobileNo == delivery.text))
                                          .toList()
                                          .length >
                                      0) {
                                    Driver dData = driver
                                        .where((i) =>
                                            (i.mobileNo == delivery.text))
                                        .toList()[0];
                                    return ListTile(
                                      title: Text("Name: " + dData.name),
                                    );
                                  } else {
                                    return Opacity(opacity: 0);
                                  }
                                },
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              if (driver
                                      .where(
                                          (i) => (i.mobileNo == delivery.text))
                                      .toList()
                                      .length ==
                                  0)
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      dark,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            CreateDriver(
                                          mobile: delivery.text,
                                          company: deliveryValue,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Add Delivery",
                                  ),
                                ),
                              if (driver
                                      .where(
                                          (i) => (i.mobileNo == delivery.text))
                                      .toList()
                                      .length >
                                  0)
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      dark,
                                    ),
                                  ),
                                  onPressed: () {
                                    Driver dData = driver
                                        .where((i) =>
                                            (i.mobileNo == delivery.text))
                                        .toList()[0];
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            CreateDriver(
                                                mobile: delivery.text,
                                                name: dData.name),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Update Delivery",
                                  ),
                                ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Portrait extends StatefulWidget {
  Portrait({Key key}) : super(key: key);

  @override
  _PortraitState createState() => _PortraitState();
}

class _PortraitState extends State<Portrait> {
  final TextEditingController contact = TextEditingController();
  final TextEditingController delivery = TextEditingController();
  final TextEditingController discount = TextEditingController();
  final TextEditingController cash = TextEditingController();
  final TextEditingController card = TextEditingController();
  final TextEditingController cardNo = TextEditingController();
  bool cardErrorFlag = false;
  int customerId = 0;
  int deriverId = 0;
  int paymentType = 1;
  int invoiceType = 1;
  double change = 0;
  double discountAmount = 0;
  List<String> disType = [
    "Discount %",
    "Discount AED",
  ];
  double cardAmount = 0;
  double cashAmount = 0;
  List<String> cardType = [
    "Master",
    "Visa",
  ];
  List<DeliveryCompany> deliveryComp = [];
  int disValue = 0;
  int cardValue = 0;
  int deliveryValue = 0;
  changeDis(int val) {
    setState(() {
      disValue = val;
    });
  }

  changeCard(int val) {
    setState(() {
      cardValue = val;
    });
  }

  changeDelivery(int val) {
    setState(() {
      deliveryValue = val;
    });
  }

  getCustData() async {
    List<Customer> data = await getCustomer();
    if (mounted) {
      setState(() {
        cust = data;
      });
    }
  }

  List<Driver> driver = [];
  getDeliveryData() async {
    List<Driver> data = await getDeriver();
    if (mounted) {
      setState(() {
        driver = data;
      });
    }
  }

  getDeliveryCompanyData() async {
    List<DeliveryCompany> data = await getDeliveryCompany();
    if (mounted) {
      setState(() {
        deliveryComp = data;
      });
    }
  }

  List<Customer> cust = [];
  List<CartProduct> cartProduct = [];
  double total = 0;
  double subtotal = 0;
  double taxAmount = 0;
  getCartProduct() async {
    TaxManagement tax = TaxManagement();
    List<CartProduct> data = await DatabaseHelper.instance.queryCart();
    if (mounted) {
      setState(() {
        cartProduct = data;
        subtotal = tax.getSubTotal(data);
        total = tax.getTotal(data);
        taxAmount = tax.getTotalTax(data);
      });
    }
  }

  manageTotalData({String discount}) async {
    // double totalData = 0;
    double discountData = 0;
    try {
      discountData = double.parse(discount);
    } catch (e) {
      discountData = 0;
    }

    TaxManagement tax = TaxManagement();
    List<CartProduct> data = await DatabaseHelper.instance.queryCart();
    // print("product code " + data[0].productCat);
    if (mounted) {
      setState(() {
        cartProduct = data;
        total = tax.getTotalWithDiscount(data, discountData, disValue);
        cash.text = total.toStringAsFixed(2);
        taxAmount = tax.getTotalTaxWithDiscount(data, discountData, disValue);
        discountAmount = tax.getDiscount(data, discountData, disValue);
        if (double.parse(cash.text) > total) {
          change = total - double.parse(cash.text);
        } else {
          change = 0;
        }
      });
    }
    // return totalData;
  }

  @override
  void initState() {
    super.initState();
    discount.text = "0";

    if (mounted) {
      getCustData();
      getDeliveryData();
      getCartProduct();
      manageTotalData(discount: "0");
      cardAmount = 0;
      // cash.text = total.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 8;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(secondary),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => POSPage(),
                        ),
                        ModalRoute.withName("/pos"),
                      );
                      // Navigator.pop(context);
                    },
                    child: Text("Back"),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(secondary),
                    ),
                    onPressed: () async {
                      await DatabaseHelper.instance.truncateCart();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => POSPage(),
                        ),
                        ModalRoute.withName("/pos"),
                      );
                    },
                    child: Text("cancel"),
                  ),
                ),
              ),
            ],
          ),
          Container(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(success),
                  ),
                  onPressed: () async {
                    String payType = "";
                    switch (paymentType) {
                      case 1:
                        payType = "Cash";
                        break;
                      case 2:
                        payType = "Card";
                        break;
                      case 3:
                        payType = "Cash & card";
                        break;
                      case 4:
                        payType = "Delivery company";
                        break;
                      default:
                        break;
                    }
                    String card = (cardValue == 1) ? "Master" : "Visa";
                    String discountType = (disValue == 0)
                        ? "DISCOUNT_BY_PERCENTAGE"
                        : "DISCOUNT_BY_AMOUNT";
                    switch (paymentType) {
                      case 1:
                        if (double.parse(cash.text) < total) {
                          cash.text = total.toString();
                        }
                        break;
                      case 2:
                        if (cardNo.text.length == 0) {
                          setState(() {
                            cardErrorFlag = true;
                          });
                        } else {
                          setState(() {
                            cardErrorFlag = false;
                          });
                        }
                        break;
                      case 3:
                        setState(() {
                          cardAmount = total - double.parse(cash.text);
                        });
                        if (cardNo.text.length == 0) {
                          setState(() {
                            cardErrorFlag = true;
                          });
                        } else {
                          setState(() {
                            cardErrorFlag = false;
                          });
                        }
                        break;
                    }
                    if (cardErrorFlag && paymentType != 1) {
                      return;
                    }
                    bool data = await placeOrder(
                      payType: payType,
                      cardType: card,
                      cardNumber: cardNo.text,
                      cardAmount: cardAmount.toString(),
                      cashAmount: cash.text,
                      customerId: customerId,
                      discount: double.parse(discount.text),
                      discountAmount: discountAmount,
                      discountType: discountType,
                      driverId: deriverId,
                      subTotal: subtotal,
                      total: total,
                      totalTax: taxAmount,
                      // context: context,
                    );
                    if (data) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ResponsePage(
                            successFlag: true,
                          ),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ResponsePage(
                            successFlag: false,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Validate And Pay " + total.toStringAsFixed(2) + " AED",
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Payment Details"),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      color: light,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Amount To be paid ",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              total.toStringAsFixed(2) + " AED",
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: success,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Subtotal: ",
                                      style: TextStyle(
                                        color: dark.withOpacity(0.5),
                                      ),
                                    ),
                                    Text(
                                      subtotal.toString() + " AED",
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Discount: ",
                                      style: TextStyle(
                                        color: dark.withOpacity(0.5),
                                      ),
                                    ),
                                    Text(
                                      discount.text +
                                          ((disValue == 0) ? "%" : "AED"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Total tax: ",
                                      style: TextStyle(
                                        color: dark.withOpacity(0.5),
                                      ),
                                    ),
                                    Text((taxAmount.toStringAsFixed(2)) +
                                        " AED"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Change remaining: ",
                                      style: TextStyle(
                                        color: dark.withOpacity(0.5),
                                      ),
                                    ),
                                    Text(change.toStringAsFixed(2) + " AED"),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select payment type'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          width: double.infinity,
                          color: light,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    paymentType = 1;
                                  });
                                },
                                child: Container(
                                  color: (paymentType == 1)
                                      ? primary.withOpacity(0.2)
                                      : light.withOpacity(0.1),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text("Cash"),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    paymentType = 2;
                                    change = 0;
                                    card.text = total.toString();
                                  });
                                },
                                child: Container(
                                  color: (paymentType == 2)
                                      ? primary.withOpacity(0.2)
                                      : light.withOpacity(0.1),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text("Card"),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(
                                    () {
                                      paymentType = 3;
                                      if (double.parse(cash.text) > total) {
                                        cash.text = total.toString();
                                        card.text =
                                            (total - double.parse(cash.text))
                                                .toString();
                                      }

                                      change = 0;
                                    },
                                  );
                                },
                                child: Container(
                                  color: (paymentType == 3)
                                      ? primary.withOpacity(0.2)
                                      : light.withOpacity(0.1),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text("Cash & card"),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    paymentType = 4;
                                    change = 0;
                                  });
                                },
                                child: Container(
                                  color: (paymentType == 4)
                                      ? primary.withOpacity(0.2)
                                      : light.withOpacity(0.1),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text("Delivery company"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              color: light,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                invoiceType = 1;
                              });
                            },
                            child: Container(
                              height: 64,
                              decoration: BoxDecoration(
                                color: (invoiceType == 1)
                                    ? dark
                                    : light.withOpacity(0.1),
                                border: Border.all(
                                  color: dark,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Dine in",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (invoiceType == 1) ? light : dark,
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
                                invoiceType = 2;
                              });
                            },
                            child: Container(
                              height: 64,
                              decoration: BoxDecoration(
                                color: (invoiceType == 2)
                                    ? dark
                                    : light.withOpacity(0.1),
                                border: Border.all(
                                  color: dark,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Delivery",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (invoiceType == 2) ? light : dark,
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
                                invoiceType = 3;
                              });
                            },
                            child: Container(
                              height: 64,
                              decoration: BoxDecoration(
                                color: (invoiceType == 3)
                                    ? dark
                                    : light.withOpacity(0.1),
                                border: Border.all(
                                  color: dark,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Take away",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (invoiceType == 3) ? light : dark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputField(
                          onChange: (val) {
                            manageTotalData(discount: val);
                          },
                          tag: "Discount:",
                          controller: discount,
                          padding: EdgeInsets.symmetric(
                            vertical: 0.8,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        CustomDropdown(
                          tag: "Distype Type",
                          item: disType,
                          value: disValue,
                          padding: EdgeInsets.symmetric(
                            vertical: 0.8,
                          ),
                          onTap: () {
                            manageTotalData(discount: discount.text);
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          onChange: changeDis,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        if (paymentType == 1 || paymentType == 3)
                          InputField(
                            onChange: (val) {
                              switch (paymentType) {
                                case 1:
                                  if (double.parse(cash.text) < total) {
                                    cash.text = total.toString();
                                  } else {
                                    setState(() {
                                      change = double.parse(cash.text) - total;
                                    });
                                  }
                                  break;
                                case 3:
                                  if (double.parse(cash.text) > total) {
                                    cash.text = total.toString();
                                  }
                                  setState(() {
                                    card.text =
                                        (total - double.parse(cash.text))
                                            .toString();
                                  });

                                  break;
                              }
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                            tag: "Cash:",
                            controller: cash,
                            padding: EdgeInsets.symmetric(
                              vertical: 0.8,
                            ),
                          ),
                        SizedBox(
                          height: 8,
                        ),
                        if (paymentType == 2 || paymentType == 3)
                          InputField(
                            tag: "Card:",
                            enable: false,
                            controller: card,
                            padding: EdgeInsets.symmetric(
                              vertical: 0.8,
                            ),
                          ),
                        SizedBox(
                          height: 8,
                        ),
                        if (paymentType != 1)
                          InputField(
                            tag: "Card No.:",
                            controller: cardNo,
                            padding: EdgeInsets.symmetric(
                              vertical: 0.8,
                            ),
                            onChange: (val) {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                          ),
                        if (cardErrorFlag && paymentType != 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            child: Text(
                              "Please enter card no",
                              textAlign: TextAlign.start,
                              style: TextStyle(color: danger),
                            ),
                          ),
                        SizedBox(
                          height: 8,
                        ),
                        if (paymentType == 2 || paymentType == 3)
                          CustomDropdown(
                            tag: "Card Type",
                            item: cardType,
                            value: cardValue,
                            onChange: changeCard,
                            padding: EdgeInsets.symmetric(
                              vertical: 0.8,
                            ),
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        SizedBox(
                          height: 8,
                        ),
                        if (paymentType == 4)
                          FutureBuilder(
                              future: getDeliveryCompany(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text("error"),
                                  );
                                }
                                // print(snapshot.data.length);
                                if (snapshot.hasData) {
                                  List<DeliveryCompany> data = snapshot.data;

                                  if (data.length > 0) {
                                    if (deliveryValue == 0) {
                                      deliveryValue = data[0].id;
                                    }
                                    return DynamicDropdown(
                                      tag: "Delivery Company",
                                      item: data,
                                      value: deliveryValue,
                                      onChange: changeDelivery,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 0.8,
                                      ),
                                      onTap: () {
                                        FocusScope.of(context).requestFocus(
                                          FocusNode(),
                                        );
                                      },
                                    );
                                  } else {
                                    return Center(
                                      child: Text("No Delivery Company found"),
                                    );
                                  }
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor: primary,
                                      color: secondary,
                                    ),
                                  );
                                }
                              }),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                    if (invoiceType != 2)
                      Container(
                        width: width * 2,
                        child: Opacity(
                          opacity: 0,
                        ),
                      ),
                    if (invoiceType == 2)
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InputField(
                              tag: "Contact No:",
                              controller: contact,
                              padding: EdgeInsets.symmetric(
                                vertical: 0.8,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            FutureBuilder(
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (cust
                                        .where(
                                            (i) => (i.mobileNo == contact.text))
                                        .toList()
                                        .length >
                                    0) {
                                  Customer cData = cust
                                      .where(
                                          (i) => (i.mobileNo == contact.text))
                                      .toList()[0];
                                  return ListTile(
                                    title: Text("Name: " + cData.name),
                                    subtitle: Text(
                                      "Address: " +
                                          cData.address +
                                          "\n Landmark: " +
                                          cData.landmark,
                                    ),
                                    isThreeLine: true,
                                  );
                                } else {
                                  return Opacity(opacity: 0);
                                }
                              },
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            if (cust
                                    .where((i) => (i.mobileNo == contact.text))
                                    .toList()
                                    .length ==
                                0)
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    dark,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          CreateCustomer(
                                        mobile: contact.text,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Add Customer",
                                ),
                              ),
                            if (cust
                                    .where((i) => (i.mobileNo == contact.text))
                                    .toList()
                                    .length >
                                0)
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    dark,
                                  ),
                                ),
                                onPressed: () {
                                  Customer cData = cust
                                      .where(
                                          (i) => (i.mobileNo == contact.text))
                                      .toList()[0];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          CreateCustomer(
                                        mobile: cData.mobileNo,
                                        name: cData.name,
                                        address: cData.address,
                                        landmark: cData.landmark,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Update Customer",
                                ),
                              ),
                            SizedBox(
                              height: 8,
                            ),
                            InputField(
                              tag: "Driver No:",
                              controller: delivery,
                              padding: EdgeInsets.symmetric(
                                vertical: 0.8,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            FutureBuilder(
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (driver
                                        .where((i) =>
                                            (i.mobileNo == delivery.text))
                                        .toList()
                                        .length >
                                    0) {
                                  Driver dData = driver
                                      .where(
                                          (i) => (i.mobileNo == delivery.text))
                                      .toList()[0];
                                  return ListTile(
                                    title: Text("Name: " + dData.name),
                                  );
                                } else {
                                  return Opacity(opacity: 0);
                                }
                              },
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            if (driver
                                    .where((i) => (i.mobileNo == delivery.text))
                                    .toList()
                                    .length ==
                                0)
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    dark,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          CreateDriver(
                                        mobile: delivery.text,
                                        company: deliveryValue,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Add Delivery",
                                ),
                              ),
                            if (driver
                                    .where((i) => (i.mobileNo == delivery.text))
                                    .toList()
                                    .length >
                                0)
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    dark,
                                  ),
                                ),
                                onPressed: () {
                                  Driver dData = driver
                                      .where(
                                          (i) => (i.mobileNo == delivery.text))
                                      .toList()[0];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          CreateDriver(
                                              mobile: delivery.text,
                                              name: dData.name),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Update Delivery",
                                ),
                              ),
                            SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final String tag;
  final EdgeInsets padding;
  final Function(String) onChange;
  final TextEditingController controller;
  final TextInputType keyType;
  final bool enable;
  const InputField({
    Key key,
    this.tag = "",
    this.controller,
    this.padding = const EdgeInsets.all(0),
    this.keyType = TextInputType.number,
    this.onChange,
    this.enable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding,
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextFormField(
          textInputAction: TextInputAction.go,
          controller: controller,
          enabled: enable,
          onEditingComplete: () {
            if (onChange != null) {
              onChange(controller.text);
            }
          },
          onFieldSubmitted: (val) {
            if (onChange != null) {
              onChange(val);
            }
          },
          keyboardType: keyType,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: primary,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: primary,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDropdown extends StatefulWidget {
  final EdgeInsets padding;
  final Function() onTap;
  final Function(int val) onChange;
  final String tag;
  final List<String> item;
  final int value;
  const CustomDropdown({
    Key key,
    @required this.onTap,
    @required this.onChange,
    this.padding = const EdgeInsets.all(0),
    this.tag = "",
    this.item,
    this.value,
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: widget.padding,
            child: Text(
              widget.tag,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: primary,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  isExpanded: true,
                  itemHeight: 64,
                  // menuMaxHeight: 64,
                  icon: Icon(Icons.arrow_drop_down),
                  value: widget.value,
                  onChanged: (int val) {
                    widget.onChange(val);
                  },
                  items: widget.item.map((e) {
                    return DropdownMenuItem(
                      value: widget.item.indexOf(e),
                      child: Text(e),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DynamicDropdown extends StatefulWidget {
  final EdgeInsets padding;
  final Function() onTap;
  final Function(int val) onChange;
  final String tag;
  final List<DeliveryCompany> item;
  final int value;

  DynamicDropdown({
    Key key,
    this.padding,
    this.onTap,
    this.onChange,
    this.tag,
    this.item,
    this.value,
  }) : super(key: key);

  @override
  _DynamicDropdownState createState() => _DynamicDropdownState();
}

class _DynamicDropdownState extends State<DynamicDropdown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: widget.padding,
          child: Text(
            widget.tag,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: primary,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                hint: Text("Please select delivery company"),
                isExpanded: true,
                itemHeight: 64,
                value: (widget.value != 0) ? widget.value : widget.item[0].id,
                // menuMaxHeight: 64,
                // underline: ,
                icon: Icon(Icons.arrow_drop_down),

                onChanged: (int val) {
                  widget.onChange(val);
                },
                items: widget.item.map((e) {
                  return DropdownMenuItem(
                    value: e.id,
                    child: Text(e.name),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
