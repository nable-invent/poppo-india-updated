import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class ProceedOrder2 extends StatefulWidget {
  ProceedOrder2({Key key}) : super(key: key);

  @override
  _ProceedOrder2State createState() => _ProceedOrder2State();
}

class _ProceedOrder2State extends State<ProceedOrder2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
          child: LayoutGrid(
        columnSizes: [4.5.fr, 100.px, auto, 1.fr],
        rowSizes: [
          auto,
          100.px,
          1.fr,
        ],
        children: [],
      )),
    );
  }
}
