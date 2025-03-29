import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30), // Icône plus grande
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.compare_arrows, size: 30), // Icône plus grande
          label: 'النشاط',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline, size: 30), // Icône plus grande
          label: 'الإجراء',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people, size: 30), // Icône plus grande
          label: 'المستخدمين',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz, size: 30), // Icône plus grande
          label: 'المزيد',
        ),
      ],
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(
        fontSize: 16, // Taille du texte sélectionné
        fontWeight: FontWeight.bold, // Gras pour le texte sélectionné
        fontFamily: 'Droid', // Police de caractères
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14, // Taille du texte non sélectionné
        fontWeight: FontWeight.normal, // Texte non sélectionné en normal
        fontFamily: 'Droid', // Police de caractères
      ),
    );
  }
}
