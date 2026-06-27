// custom_input_number.dart
import 'package:chira/common/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomInputNumber extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final double? height;
  final double? width;
  final double? fontSize;
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  const CustomInputNumber({
    super.key,
    this.controller,
    required this.hintText,
    this.height,
    this.width,
    this.fontSize,
    this.initialValue,
    this.onChanged,
  }) : assert(controller == null || initialValue == null, 
           'Cannot provide both a controller and an initialValue');

  @override
  _CustomInputNumberState createState() => _CustomInputNumberState();
}

class _CustomInputNumberState extends State<CustomInputNumber> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? 
        TextEditingController(text: widget.initialValue);
    if (widget.onChanged != null) {
      _internalController.addListener(() {
        widget.onChanged!(_internalController.text);
      });
    }
  }

  @override
  void dispose() {
    // Ne disposez que si nous avons créé le contrôleur nous-mêmes
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: SizedBox(
        height: widget.height ?? 50,
        width: widget.width ?? 300,
        child: TextField(
          controller: _internalController,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: widget.fontSize ?? 18,
          ),
          decoration: InputDecoration(
            focusColor: greenCustomColor,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: widget.fontSize ?? 18,
              fontFamily: 'Droid',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: greenCustomColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}