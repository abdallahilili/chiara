import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:chira/features/home/widgets/action_button_widget.dart';

class ActionButtonsSection extends StatelessWidget {
  final VoidCallback onCreateOrderPressed;
  final VoidCallback? onPurchasePressed;
  final VoidCallback? onOverviewPressed;
  final VoidCallback? onDebtBookPressed;

  const ActionButtonsSection({
    Key? key,
    required this.onCreateOrderPressed,
    this.onPurchasePressed,
    this.onOverviewPressed,
    this.onDebtBookPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Première rangée de boutons
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: LucideIcons.listOrdered,
                label: 'انشاء طلبية',
                onPressed: onCreateOrderPressed,
                backgroundColor: Colors.blue.shade50,
                borderColor: Colors.blue.shade200,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                icon: LucideIcons.shoppingCart,
                label: 'عملية شراء',
                onPressed: onPurchasePressed ?? () {},
                backgroundColor: Colors.green[50],
                borderColor: Colors.green[200],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Deuxième rangée de boutons
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: LucideIcons.pieChart,
                label: 'نظرة عامة',
                onPressed: onOverviewPressed ?? () {},
                backgroundColor: Colors.orange.shade50,
                borderColor: Colors.orange.shade200,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                icon: LucideIcons.book,
                label: 'دفتر الديون',
                onPressed: onDebtBookPressed ?? () {},
                backgroundColor: Colors.red.shade50,
                borderColor: Colors.red.shade200,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
