import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double? height;
  final double? width;
  final double? fontSize;
  final int? maxLines;

  const CustomInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.height,
    this.width,
    this.fontSize,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: SizedBox(
        height: height ??
            (maxLines != null && maxLines! > 1 ? maxLines! * 24.0 : 50),
        width: width ?? 300,
        child: TextField(
          controller: controller,
          maxLines: maxLines ?? 1,
          style: TextStyle(
            fontSize: fontSize ?? 18,
            fontFamily: 'Droid',
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: fontSize ?? 18,
              fontFamily: 'Droid',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
