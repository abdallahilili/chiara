import 'package:chira/common/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double? height;
  final double? width;
  final double? fontSize;

  const CustomInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.height,
    this.width,
    this.fontSize, // Ajouter cette propriété dans le constructeur
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: SizedBox(
        height: height ??
            50, // Utilise une hauteur par défaut si elle n'est pas spécifiée
        width: width ??
            300, // Utilise une largeur par défaut si elle n'est pas spécifiée
        child: TextField(
          controller: controller,
          style: TextStyle(
            fontSize: fontSize ?? 18, // Contrôlez la taille du texte ici
            fontFamily: 'Droid', // Contrôlez la taille du texte ici
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: fontSize ?? 18, // Contrôlez la taille du texte ici
              fontFamily: 'Droid', // Contrôlez la taille du texte ici
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
