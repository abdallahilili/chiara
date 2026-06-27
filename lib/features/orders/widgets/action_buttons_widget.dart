import 'package:flutter/material.dart';
import 'package:chira/common/widgets/custom_button.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const ActionButtonsWidget({
    Key? key,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'حفظ',
            onPressed: onSave,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomButton(
            text: 'إلغاء',
            onPressed: onCancel,
          ),
        ),
      ],
    );
  }
}
