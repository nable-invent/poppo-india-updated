import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:poppos/Utills/Color.dart';

class MyToast {
  show({String msg = ""}) {
    Fluttertoast.showToast(
      msg: msg,
      timeInSecForIosWeb: 1,
      backgroundColor: secondary,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
