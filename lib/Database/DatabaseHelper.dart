// import 'package:dio/dio.dart';
import 'package:poppos/Model/CartProduct.dart';
import 'package:poppos/Model/GroupsModel.dart';
import 'package:poppos/Networking/ModelToDB.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';

import '../Model/ProductsModel.dart';

// class Product {
//   String productName;
//   String productImage;
//   Product({
//     this.productName,
//     this.productImage,
//   });
// }
class DatabaseHelper {
  static final _dbName = 'demodb';
  static final _dbVersion = 1;
  //product
  static final tblProduct = 'tbl_product';
  static final productPK = "product_pk";
  static final productId = 'product_id';
  static final productCode = 'product_code';
  static final productName = 'product_name';
  static final productPrice = 'product_price';
  static final productImage = 'product_image';
  static final productCategory = 'product_category';
  static final productVat = 'product_vat';
  static final productIsActive = 'product_isactive';
  //cart

  static final tblCart = 'tbl_cart';
  static final cartId = 'cart_id';
  static final cartProductId = 'cart_productid';
  static final cartProductCode = 'cart_productcode';
  static final cartProductCat = 'cart_productcat';
  static final cartProductName = 'cart_productname';
  static final cartProductPrice = 'cart_productprice';
  static final cartProductCount = 'cart_productcount';
  static final cartProductImage = 'cart_productimage';
  static final cartProductTax = 'cart_productTax';
//Group

  static final tblGroup = 'tbl_group';
  static final groupPk = 'group_id';
  static final groupId = 'group_groupid';
  static final groupCode = 'group_code';
  static final groupName = 'group_name';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tblProduct (
            $productPK INTEGER PRIMARY KEY autoincrement,
            $productId INTEGER NULL,
            $productCode TEXT  NULL,
            $productName TEXT  NULL,
            $productPrice DOUBLE  NULL,
            $productImage TEXT  NULL,
            $productCategory TEXT  NULL,
            $productVat TEXT NULL,
            $productIsActive INTEGER  NULL
          )
      ''');

    await db.execute('''
      CREATE TABLE $tblCart (
            $cartId INTEGER PRIMARY KEY autoincrement,
            $cartProductId INTEGER NOT NULL,
            $cartProductCode TEXT  NULL,
            $cartProductCat TEXT  NULL,
            $cartProductName TEXT NOT NULL,
            $cartProductPrice DOUBLE NOT NULL,
            $cartProductImage TEXT NOT NULL,
            $cartProductCount INTEGER NOT NULL,
            $cartProductTax TEXT NULL

          )
      ''');
    await db.execute('''
      CREATE TABLE $tblGroup (
            $groupPk INTEGER PRIMARY KEY autoincrement,
            $groupId INTEGER  NULL,
            $groupName TEXT  NULL
          )
      ''');
  }

  Future<int> insertProduct(Map<String, dynamic> row) async {
    // try {
    Database db = await instance.database;
    return await db.insert(tblProduct, row);
    // } catch (e) {
    //   print('error===>' + e);
    //   return 1;
    // }
  }

  Future<int> insertCart(Map<String, dynamic> row) async {
    // try {
    print(row);
    Database db = await instance.database;
    return await db.insert(tblCart, row);
    // } catch (e) {
    //   print('error===>');
    //   return 1;
    // }
  }

  Future<int> insertGroup(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert("$tblGroup", row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(tblProduct);
  }

  Future<List<Products>> queryAllProduct() async {
    Database db = await instance.database;
    List<Products> sendData = [];
    dynamic data = await db.query("$tblProduct");
    for (dynamic res in data) {
      // print("productName:"+res['name'])
      Products prod = Products(
        productId: res[productId],
        productName: res[productName],
        productCode: res[productCode],
        productPrice: res[productPrice].toString(),
        productCategory:
            (res[productCategory] != null) ? res[productCategory] : "0",
        productImage:
            (res[productImage] != null) ? res[productImage] : "dummy.png",
        productVAT:
            (res[productVat] != null) ? double.parse(res[productVat]) : 0,
        isActive: 0,
      );
      sendData.add(prod);
    }
    return sendData;
  }

  Future<List<CartProduct>> queryCart() async {
    Database db = await instance.database;
    List<CartProduct> sendData = [];
    dynamic data = await db.query("$tblCart");
    print(data.length);
    for (dynamic res in data) {
      // print("productName:"+res['name'])
      CartProduct prod = CartProduct(
        productId: res[cartProductId],
        name: res[cartProductName],
        productCode: res[cartProductCode],
        productCat: res[cartProductCat],
        price: res[cartProductPrice].toString(),
        image: (res[cartProductPrice] != null)
            ? res[cartProductImage]
            : "dummy.png",
        count: res[cartProductCount],
        tax: double.parse(res[cartProductTax]),
      );
      sendData.add(prod);
    }
    return sendData;
  }

  Future<List<Groups>> queryAllGroups() async {
    Database db = await instance.database;
    List<Groups> groupList = [];
    List<Map<String, dynamic>> data = await db.query("$tblGroup");
    for (dynamic res in data) {
      Groups g = Groups(
        groupId: res[groupId],
        groupCode: res[groupCode],
        groupName: res[groupName],
      );
      groupList.add(g);
    }
    return groupList;
  }

  truncateProduct() async {
    Database db = await instance.database;
    await db.execute("DELETE FROM $tblProduct");
  }

  truncateCart() async {
    Database db = await instance.database;
    await db.execute("DELETE FROM $tblCart");
  }

  truncateGroup() async {
    Database db = await instance.database;
    await db.execute("DELETE FROM $tblGroup");
  }

  Future update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update("demotab", row, where: 'id = ?', whereArgs: [id]);
  }

  Future updateCart(Map<String, dynamic> row, int cartid) async {
    Database db = await instance.database;
    int id = cartid;
    return await db
        .update(tblCart, row, where: '$cartProductId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete("demotab", where: "id=?", whereArgs: [id]);
  }

  Future<int> deleteCart(int id) async {
    Database db = await instance.database;
    return await db.delete(tblCart, where: "$cartProductId=?", whereArgs: [id]);
  }

  Future<bool> createTable(String tablename, List<Table> column) async {
    bool response = false;
    try {
      Database db = await instance.database;

      String columnData = '';
      columnData += tablename + "_id" + "  INTEGER PRIMARY KEY autoincrement,";
      for (dynamic res in column) {
        columnData +=
            res.columnName + " " + res.columnType + " " + res.isNull + ",";
      }
      if (columnData != null && columnData.length > 0) {
        columnData = columnData.substring(0, columnData.length - 1);
      }
      await db.execute(
          'CREATE TABLE if not exists $tablename ( ' + columnData + ' )');
      response = true;
    } catch (e) {
      print(e);
    }
    return response;
  }

  Future<int> deleteTableData(int id, String key, String table) async {
    Database db = await instance.database;
    return await db.delete(table, where: "$key=?", whereArgs: [id]);
  }

  Future updateTableData(
      Map<String, dynamic> row, String key, int id, String table) async {
    Database db = await instance.database;

    return await db.update(table, row, where: '$key = ?', whereArgs: [id]);
  }

  truncateTable(String table) async {
    Database db = await instance.database;
    await db.execute("DELETE FROM $table");
  }

  Future<List<Map<String, dynamic>>> queryAllTableData({String table}) async {
    Database db = await instance.database;
    return await db.query("$table");
  }

  Future<List<Map<String, dynamic>>> queryAllTableWhereData({
    String table,
    dynamic id,
    String key,
  }) async {
    Database db = await instance.database;
    return await db.query("$table", where: '$key = ?', whereArgs: [id]);
  }

  Future<int> insertTable(Map<String, dynamic> row, table) async {
    Database db = await instance.database;
    return await db.insert("$table", row);
  }
}
