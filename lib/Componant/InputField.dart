import 'package:flutter/material.dart';
import '../Utills/Color.dart';

class InputField extends StatelessWidget {
  final bool autocurrect;
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  const InputField({
    Key key,
    this.autocurrect = true,
    this.controller,
    this.label = "",
    this.isPassword = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 16,
        ),
        TextField(
          obscureText: isPassword,
          autocorrect: autocurrect,
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            fillColor: primary,
          ),
        ),
      ],
    );
  }
}

class SidelabelInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const SidelabelInput({
    Key key,
    this.label,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: dark.withOpacity(0.5),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
