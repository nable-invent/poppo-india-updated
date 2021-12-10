// import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:poppos/Database/DatabaseHelper.dart';
import 'package:poppos/Networking/Networking.dart';
import 'package:poppos/Networking/OfflineData.dart';
import 'Url.dart';

class Products {
  final int productId;
  final String productCode;
  final String productName;
  final String productPrice;
  final String productImage;
  final String productCategory;
  final double productVAT;
  int isActive;
  Products({
    this.productId,
    this.productCode,
    this.productName,
    this.productPrice,
    this.productImage,
    this.productCategory,
    this.productVAT,
    this.isActive,
  });
}

Future<List<Products>> getProducts({bool mode = false}) async {
  List<Products> productList = [];
  if (await checkConnectivity() && mode) {
  } else {
    return await getProductOffline();
  }

  return productList;
}

Future<List<Products>> productsOfflineData(String outlet) async {
  List<Products> productList = [];

  Dio dio = Dio();
  String token = await getOfflineData("token");
  String apiData = await getOfflineData("url");
  dynamic response = await dio.get(
    api + apiData + routes(key: "listproduct") + outlet,
    options: Options(headers: {
      "Authorization": "Token " + token,
    }),
  );

  if (response.statusCode == 200) {
    dynamic data = response.data;
    for (dynamic res in data) {
      if (res['category'] == "combo") {
        Products g = Products(
          productId: res['id'],
          productCode: res['item_code'],
          productName: res['name'],
          productPrice: res['sales_price'],
          productCategory: "combo",
          productImage: (res['image'] != null) ? res['image'] : "dummy.png",
          productVAT: double.parse(res['vat_percentage']),
          isActive: 0,
        );
        productList.add(g);
      } else {
        Products g = Products(
          productId: res['id'],
          productCode: res['item_code'],
          productName: res['name'],
          productPrice: res['sales_price'],
          productCategory: (res['category'] != null)
              ? (res['category']['id']).toString()
              : "0",
          productImage: (res['image'] != null) ? res['image'] : "/dummy.png",
          productVAT: double.parse(res['vat_percentage']),
          isActive: 0,
        );
        productList.add(g);
      }
    }
  }

  return productList;
}

Future<List<Products>> getProductOffline() async {
  List<Products> getData = await DatabaseHelper.instance.queryAllProduct();

  return getData;
}

goToOfflineProduct(String outlet) async {
  // print("Offline");
  List<Products> check = await DatabaseHelper.instance.queryAllProduct();
  if (check.length == 0) {}
  await DatabaseHelper.instance.truncateProduct();
  List<Products> data = await productsOfflineData(outlet);
  for (dynamic res in data) {
    await DatabaseHelper.instance.insertProduct({
      DatabaseHelper.productId: res.productId,
      DatabaseHelper.productCode: res.productCode,
      DatabaseHelper.productName: res.productName,
      DatabaseHelper.productPrice: double.parse(res.productPrice),
      DatabaseHelper.productCategory: res.productCategory,
      DatabaseHelper.productImage: res.productImage,
      DatabaseHelper.productVat: res.productVAT.toString(),
      DatabaseHelper.productIsActive: res.isActive,
    });
    // print("response" + i.toString());
  }
  // List<Products> getData = await DatabaseHelper.instance.queryAllProduct();
  // print(getData[0].productPrice.toString());
}
