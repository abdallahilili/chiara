import 'package:flutter/material.dart';
import 'package:chira/features/home/widgets/favorite_contact_widget.dart';
import 'package:chira/features/home/widgets/add_favorite_button.dart';

class FavoritesSection extends StatelessWidget {
  const FavoritesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أشخاصك المفضلين',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Droid',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const AddFavoriteButton(),
            const SizedBox(width: 16),
            FavoriteContactWidget(
              name: 'غريس ل.',
              backgroundColor: Colors.pink[200],
              onTap: () {
                // Action pour sélectionner ce contact
              },
            ),
            const SizedBox(width: 16),
            FavoriteContactWidget(
              name: 'لورانس أ.',
              backgroundColor: Colors.blue[200],
              onTap: () {
                // Action pour sélectionner ce contact
              },
            ),
          ],
        ),
      ],
    );
  }
}
