import 'package:flutter/material.dart';
import 'package:chira/common/widgets/custom_input_number.dart';

class AmountInputWidget extends StatelessWidget {
  final TextEditingController controller;

  const AmountInputWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomInputNumber(
      controller: controller,
      hintText: 'المبلغ المرسل',
    );
  }
}
