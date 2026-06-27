import 'package:chira/common/widgets/custom_button.dart';
import 'package:chira/features/purchases/screens/free_purchase_page.dart';
import 'package:chira/features/purchases/screens/request_selection_page.dart';
import 'package:flutter/material.dart';

class PurchaseTypeDialog extends StatelessWidget {
  const PurchaseTypeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'اختر نوع الشراء',
        style: TextStyle(fontFamily: 'Droid'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomButton(
  onPressed: () {
    Navigator.pop(context); // Ferme le dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestSelectionPage(
          shopId: '008', // Remplacez par l'ID réel de la boutique
        ),
      ),
    );
  },
  text: 'شراء حسب طلب',
),
          const SizedBox(height: 10),
          CustomButton(
            onPressed: () {
              Navigator.pop(context); // Ferme le dialog
              // Naviguer vers la page "achat libre"
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FreePurchasePage(),
                ),
              );
            },
            text: 'شراء حر (بدون طلب)',
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text(
            'إلغاء',
            style: TextStyle(fontFamily: 'Droid'),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Ferme le dialog
          },
        ),
      ],
    );
  }
}