import 'package:flutter/material.dart';

class DummyPage extends StatelessWidget {
  final String text;
  const DummyPage({
    Key key,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Text(text),
        ),
      ),
    );
  }
}
