import 'package:chira/common/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEAF6E9), // Couleur de fond vert clair
        minimumSize: const Size(150, 50), // Taille ajustée
        elevation: 0, // Pas d'ombre
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Coins arrondis
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Droid',
          color: greenCustomColor, // Texte en vert foncé
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }
}
