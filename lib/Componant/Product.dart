import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:poppos/Model/CartProduct.dart';
import 'package:poppos/Model/ProductsModel.dart';
import 'package:poppos/Model/Url.dart';
import 'package:poppos/Networking/OfflineData.dart';
import 'package:poppos/Utills/Color.dart';

class ProductCard extends StatefulWidget {
  final String productName;
  final String productPrice;
  final String productImage;

  const ProductCard({
    Key key,
    this.productName,
    this.productPrice,
    this.productImage,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String image = "";
  @override
  void initState() {
    super.initState();
    setimageurl();
  }

  setimageurl() async {
    String s = await getOfflineData("url");
    setState(() {
      image = "https://" + s;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              image + widget.productImage,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: light,
                // decoration: BoxDecoration(color: light),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.productName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Card(
                color: primary,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.productPrice + " INR",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: light,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductGrid extends StatelessWidget {
  final List<Products> data;
  final int category;
  final Function(CartProduct) onAddToCart;
  final int gridCount;
  const ProductGrid({
    Key key,
    this.data,
    this.category,
    this.onAddToCart,
    this.gridCount = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: gridCount,
      mainAxisSpacing: 32,
      crossAxisSpacing: 32,
      shrinkWrap: true,
      primary: false,
      children: data
          .where((c) =>
              (c.productCategory == category.toString() || category == null))
          .map((e) {
        return GestureDetector(
          onTap: () {
            CartProduct prod = CartProduct(
              productId: e.productId,
              productCode: e.productCode,
              productCat: e.productCategory,
              name: e.productName,
              image: e.productImage,
              price: e.productPrice,
              tax: e.productVAT,
              count: 1,
            );
            onAddToCart(prod);
          },
          child: ProductCard(
            productName: e.productName,
            productPrice: e.productPrice,
            productImage: e.productImage,
          ),
        );
      }).toList(),
    );
  }
}
