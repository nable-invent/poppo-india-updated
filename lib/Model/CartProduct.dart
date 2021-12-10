class CartProduct {
  final int productId;
  final String productCode;
  final String productCat;
  final String name;
  final String image;
  final String price;
  int count;
  final double tax;
  CartProduct({
    this.productId,
    this.productCode,
    this.productCat,
    this.name,
    this.image,
    this.price,
    this.count,
    this.tax,
  });
}
