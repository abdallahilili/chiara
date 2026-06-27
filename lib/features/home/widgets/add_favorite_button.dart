import 'package:flutter/material.dart';

class AddFavoriteButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AddFavoriteButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ??
          () {
            // Afficher une boîte de dialogue pour ajouter un nouveau contact favori
          },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(Icons.add, color: Colors.grey[600]),
      ),
    );
  }
}
