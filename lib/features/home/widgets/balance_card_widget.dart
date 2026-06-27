import 'package:flutter/material.dart';
import 'package:chira/common/utils/colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BalanceCardWidget extends StatelessWidget {
  final String? userName;

  const BalanceCardWidget({
    Key? key,
    this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
      color: const Color(0xFFEAF6E9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: greenCustomColor,
              child: Icon(LucideIcons.wallet2, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحبًا، ${userName ?? 'المستخدم'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Droid',
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text(
                      '1,234',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Droid',
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'أوقية',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'Droid',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
