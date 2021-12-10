import 'package:flutter/material.dart';
import '../Utills/Color.dart';

class FilterButton extends StatelessWidget {
  final String title;
  final Color borderColor;
  final double borderWidth;
  final Function(int) onChange;
  final bool isSelect;

  final int category;
  const FilterButton({
    Key key,
    this.title = "",
    this.borderColor,
    this.borderWidth = 1,
    this.onChange,
    this.category,
    this.isSelect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      child: (!isSelect)
          ? OutlinedButton(
              style: ButtonStyle(
                side: MaterialStateProperty.all(
                  BorderSide(
                    color: (borderColor != null) ? borderColor : primary,
                    width: borderWidth,
                  ),
                ),
              ),
              onPressed: () {
                onChange(category);
              },
              child: Text(
                title,
                style: TextStyle(
                  color: primary,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: () {
                onChange(category);
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(primary)),
              child: Text(
                title,
                style: TextStyle(
                  color: light,
                ),
              ),
            ),
    );
  }
}

class SolidButton extends StatelessWidget {
  final Function() onPressed;
  final Widget child;
  final Color color;
  const SolidButton({
    Key key,
    @required this.onPressed,
    this.child,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(color),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
