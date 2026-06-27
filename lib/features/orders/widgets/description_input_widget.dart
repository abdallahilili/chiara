import 'package:flutter/material.dart';
import 'package:chira/common/widgets/custom_input.dart';

class DescriptionInputWidget extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionInputWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomInput(
      controller: controller,
      hintText: 'وصف',
      maxLines: 4,
    );
  }
}
