import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poppos/Model/CartProduct.dart';
import 'package:poppos/Model/Url.dart';
// import 'package:poppos/Model/ProductsModel.dart';
// import 'package:poppos/Model/Url.dart';
import 'package:poppos/Utills/Color.dart';
import 'package:poppos/View/ProceedOrder.dart';
import '../Model/TaxManagement.dart';

class CartPage extends StatefulWidget {
  final List<CartProduct> productList;
  final Function(CartProduct) onCancel;
  final Function() placeOrder;
  CartPage({
    Key key,
    this.productList = const <CartProduct>[],
    this.onCancel,
    this.placeOrder,
  }) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double total = 0;
  double subTotal = 0;
  TaxManagement calc = TaxManagement();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              DrawerHeader(
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "SubTotal: " +
                            ((widget.productList.length > 0)
                                ? calc
                                    .getSubTotal(widget.productList)
                                    .toStringAsFixed(2)
                                : " 0 ") +
                            "INR",
                      ),
                      Text("Total: " +
                          ((widget.productList.length > 0)
                              ? calc
                                  .getTotal(widget.productList)
                                  .toStringAsFixed(2)
                              : " 0 ") +
                          " INR"),
                    ],
                  ),
                ),
              ),
              Container(
                child: FutureBuilder(
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (widget.productList.length > 0) {
                      return SingleChildScrollView(
                        child: Column(
                          children: widget.productList.map(
                            (c) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Stack(
                                  children: [
                                    ListTile(
                                      leading: Container(
                                        width: 100,
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl + c.image,
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                                  "assets/images/noimage.jpg"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(c.name),
                                      subtitle: Text(
                                        c.price + " X " + c.count.toString(),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.onCancel(c);
                                        },
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: secondary,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "X",
                                                style: TextStyle(
                                                  color: light,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      );
                    } else {
                      return Center(
                        child: Text("No Product Selected"),
                      );
                    }
                  },
                ),
              ),
              SizedBox(
                height: 100,
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // widget.placeOrder();
                  Navigator.pop(context);
                  if (widget.productList.length > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => ProceedOrder(),
                      ),
                    );
                  } else {
                    Fluttertoast.showToast(
                        msg: "Please select atleast 1 product");
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(primary),
                ),
                child: Text(
                  "Place Order",
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
