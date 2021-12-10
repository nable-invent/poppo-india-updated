import 'CartProduct.dart';

class TaxManagement {
  getSubTotal(List<CartProduct> cartProduct) {
    double subTotal = 0;
    for (CartProduct res in cartProduct) {
      subTotal += (double.parse(res.price) * res.count);
    }
    return subTotal;
  }

  getTotal(List<CartProduct> cartProduct) {
    double total = 0;
    double tax = 0;
    for (CartProduct res in cartProduct) {
      tax = (res.tax != null) ? res.tax : 0;
      // print(tax);
      // print(((double.parse(res.price) * res.count) * tax) / 100);
      total += ((double.parse(res.price) * res.count) +
          ((double.parse(res.price) * res.count) * tax) / 100);
    }
    return total;
  }

  getTotalTax(List<CartProduct> cartProduct) {
    double total = 0;
    double tax = 0;
    for (CartProduct res in cartProduct) {
      tax = (res.tax != null) ? res.tax : 0;
      total += ((double.parse(res.price) * res.count) * tax) / 100;
    }
    return total;
  }

  getTotalWithDiscount(
    List<CartProduct> cartProduct,
    double discount,
    int type,
  ) {
    double total = 0;
    double tax = 0;
    double t = 0;
    for (CartProduct res in cartProduct) {
      t += (double.parse(res.price) * res.count);
    }
    for (CartProduct res in cartProduct) {
      tax = (res.tax != null) ? res.tax : 0;
      double sub = (double.parse(res.price) * res.count);
      double wet = sub / t;
      if (type == 0) {
        double discountPrice = ((sub * discount) / 100);
        double totalWithoutTax = sub - discountPrice;
        total += (totalWithoutTax + ((totalWithoutTax * tax) / 100));
      } else {
        double discountPrice = ((wet * discount));
        double totalWithoutTax = sub - discountPrice;
        total += (totalWithoutTax + ((totalWithoutTax * tax) / 100));
      }
    }
    return total;
  }

  getTotalTaxWithDiscount(
    List<CartProduct> cartProduct,
    double discount,
    int type,
  ) {
    double total = 0;
    double tax = 0;
    double t = 0;
    for (CartProduct res in cartProduct) {
      t += (double.parse(res.price) * res.count);
    }
    for (CartProduct res in cartProduct) {
      tax = (res.tax != null) ? res.tax : 0;
      double sub = (double.parse(res.price) * res.count);
      double wet = sub / t;
      if (type == 0) {
        double discountPrice = ((sub * discount) / 100);
        double totalWithoutTax = sub - discountPrice;
        total += ((totalWithoutTax * tax) / 100);
      } else {
        double discountPrice = ((wet * discount));
        double totalWithoutTax = sub - discountPrice;
        total += ((totalWithoutTax * tax) / 100);
      }
    }
    return total;
  }

  getDiscount(
    List<CartProduct> cartProduct,
    double discount,
    int type,
  ) {
    double total = 0;
    double t = 0;
    for (CartProduct res in cartProduct) {
      t += (double.parse(res.price) * res.count);
    }
    for (CartProduct res in cartProduct) {
      double sub = (double.parse(res.price) * res.count);
      double wet = sub / t;
      if (type == 0) {
        double discountPrice = ((sub * discount) / 100);

        total += discountPrice;
      } else {
        double discountPrice = ((wet * discount));
        total += discountPrice;
      }
    }
    return total;
  }
}
