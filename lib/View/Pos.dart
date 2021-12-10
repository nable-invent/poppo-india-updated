// import 'package:flutter/foundation.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Model/Auth.dart';
import 'package:poppos/Model/OfflineModel.dart';
import 'package:poppos/Model/OrderModel.dart';
import 'package:poppos/Networking/OfflineData.dart';
import 'package:poppos/View/OrderPage.dart';
import 'package:poppos/main.dart';
import '../Componant/Buttons.dart';
import '../Componant/Cart.dart';
import '../Componant/Product.dart';
import '../Componant/Toast.dart';
import '../Model/CartProduct.dart';
import '../Model/GroupsModel.dart';
import '../Model/ProductsModel.dart';
import '../Utills/Color.dart';

class POSPage extends StatefulWidget {
  POSPage({Key key}) : super(key: key);

  @override
  _POSPageState createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  int category;
  List<CartProduct> prodList = [];
  int counter = 0;
  @override
  void initState() {
    super.initState();
    getCart();
    getOfflieOrder();
    getOrderData();
  }

  getOfflieOrder() async {
    List<Map<String, dynamic>> data =
        await DatabaseHelper.instance.queryAllTableData(table: "tbl_datalist");
    setState(() {
      counter = data.length;
    });
    await fetchDataBG();
    print(counter);
  }

  @override
  Widget build(BuildContext context) {
    // getCart();
    double col1 = MediaQuery.of(context).size.width / 8;
    int count = 2;
    // int colCount = 5;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "POPPOS",
            // style: TextStyle(
            //   fontSize: 32,
            // ),
          ),
          backgroundColor: primary,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Container(
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.topLeft,
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
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: Container(
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: TextButton(
                        onPressed: () async {
                          await DatabaseHelper.instance.truncateCart();
                          String outlet = await getOfflineData("outlet");
                          await appOffline(outlet);
                          setState(() {
                            prodList = [];
                          });
                          // await syncOrder();
                          // await logout();

                          Navigator.pop(context);
                        },
                        child: Text(
                          "Update Products",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: Container(
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: TextButton(
                        child: Row(
                          children: [
                            Text(
                              "Sync Orders",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: CircleAvatar(
                                backgroundColor: secondary,
                                radius: 9,
                                child: Text(
                                  "$counter",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          await fetchData();
                          Navigator.pop(context);
                          getOfflieOrder();
                        },
                      ),
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: Container(
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: TextButton(
                        child: Row(
                          children: [
                            Text(
                              "Remove All Orders",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: CircleAvatar(
                                backgroundColor: secondary,
                                radius: 9,
                                child: Text(
                                  "$counter",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.INFO,
                            animType: AnimType.BOTTOMSLIDE,
                            title: 'Are You Sure ?',
                            desc: 'All data will be removed permanently.',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () async {
                              await removeAllOrder();
                              getOfflieOrder();
                            },
                          )..show();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            backgroundColor: secondary,
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.add_shopping_cart,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        (prodList != null) ? prodList.length.toString() : "0",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        endDrawer: Drawer(
          elevation: 24,
          child: CartPage(
            onCancel: removeProduct,
            productList: prodList,
          ),
        ),
        drawer: Drawer(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 64.0),
                  child: Container(
                    height: 48,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(success),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => OrderPage(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("Completed"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  category = null;
                                });
                              },
                              child: Text(
                                "See All Products",
                                style: TextStyle(
                                  color: primary,
                                ),
                              ),
                            ),
                            FutureBuilder(
                              future: getGroups(mode: false),
                              builder:
                                  (BuildContext context, AsyncSnapshot ss) {
                                if (ss.hasData) {
                                  List<Groups> data = ss.data;
                                  if (data.length > 0) {
                                    return Column(
                                      children: data.map(
                                        (e) {
                                          return FilterButton(
                                            isSelect: e.groupId == category,
                                            onChange: setCategory,
                                            title: e.groupName ?? "",
                                            category: e.groupId ?? 1,
                                          );
                                        },
                                      ).toList(),
                                    );
                                  } else {
                                    return Center(
                                      child: Text("No Groups"),
                                    );
                                  }
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 800) {
              count = 4;
            } else if (constraints.maxWidth > 500) {
              count = 3;
            } else if (constraints.maxWidth > 300) {
              count = 1;
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 24,
                  ),
                  Container(
                    width: col1 * 8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        // vertical: 72.0,
                        horizontal: 24,
                      ),
                      child: FutureBuilder(
                        future: getProducts(mode: false),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Products> data = snapshot.data;
                            if (data.length > 0) {
                              return ProductGrid(
                                gridCount: count,
                                onAddToCart: addToCart,
                                category: category,
                                data: data,
                              );
                            } else {
                              return Center(
                                child: Text("No Products"),
                              );
                            }
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                backgroundColor: primary,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  setCategory(cat) {
    setState(() {
      category = cat;
    });
  }

  addToCart(CartProduct prod) async {
    MyToast toast = MyToast();

    int i = 0;
    bool flag = false;
    for (CartProduct res in prodList) {
      if (prod.productId == res.productId &&
          prod.productCat == res.productCat) {
        CartProduct newProd = CartProduct(
          productId: prod.productId,
          productCode: prod.productCode,
          productCat: prod.productCat,
          name: prod.name,
          image: prod.image,
          price: prod.price,
          count: res.count + 1,
          tax: prod.tax,
        );
        await DatabaseHelper.instance.updateCart({
          DatabaseHelper.cartProductCount: res.count + 1,
        }, prod.productId);
        setState(() {
          prodList[i] = newProd;
          flag = true;
        });

        break;
      }
      i++;
    }
    if (!flag) {
      setState(() {
        prodList.add(prod);
      });
      // print("prod tax" + prod.tax.toString());
      await DatabaseHelper.instance.insertCart({
        DatabaseHelper.cartProductId: prod.productId,
        DatabaseHelper.cartProductCode: prod.productCode,
        DatabaseHelper.cartProductCat: prod.productCat,
        DatabaseHelper.cartProductName: prod.name,
        DatabaseHelper.cartProductImage: prod.image,
        DatabaseHelper.cartProductPrice: prod.price,
        DatabaseHelper.cartProductTax: prod.tax.toString(),
        DatabaseHelper.cartProductCount: 1,
      });
      toast.show(msg: "New Product Added");
    } else {
      MyToast toast = MyToast();
      toast.show(msg: "Cart Updated");
    }
  }

  removeProduct(CartProduct prod) {
    // MyToast toast = MyToast();
    setState(
      () {
        int i = 0;
        // bool flag = false;
        for (CartProduct res in prodList) {
          if (prod.productId == res.productId) {
            CartProduct newProd = CartProduct(
              productId: prod.productId,
              productCode: prod.productCode,
              productCat: prod.productCat,
              name: prod.name ?? "",
              image: prod.image,
              price: prod.price,
              count: res.count - 1,
              tax: prod.tax,
            );
            DatabaseHelper.instance.updateCart({
              DatabaseHelper.cartProductCount: res.count - 1,
            }, prod.productId);
            prodList[i] = newProd;
            if (newProd.count == 0) {
              prodList.removeAt(i);
              DatabaseHelper.instance.deleteCart(prod.productId);
            }
            // flag = true;
            break;
          }
          i++;
        }
      },
    );
  }

  getCart() async {
    List<CartProduct> data = await DatabaseHelper.instance.queryCart();
    // print("cart data" + data[0].price);
    setState(() {
      prodList = data;
    });
  }
}
