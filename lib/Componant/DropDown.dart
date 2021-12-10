import 'package:flutter/material.dart';
import 'package:poppos/Utills/Color.dart';

class DropDown extends StatefulWidget {
  final int value;
  final Function(int) onChange;
  final List<DropdownMenuItem<dynamic>> items;
  DropDown({
    Key key,
    this.value,
    this.onChange,
    this.items,
  }) : super(key: key);

  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: grey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            value: widget.value,
            onChanged: (val) {
              widget.onChange(val);
            },
            items: widget.items,
          ),
        ),
      ),
    );
  }
}
