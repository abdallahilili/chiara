import 'package:chira/common/utils/colors.dart';
import 'package:chira/features/home/widgets/action_button_widget.dart';
import 'package:chira/features/orders/screens/create_order_page.dart';
import 'package:flutter/material.dart';
import 'package:chira/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          TextDirection.rtl, // Définit la direction du texte de droite à gauche
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chira',
            style: TextStyle(fontSize: 20, fontFamily: 'Droid'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Action pour ouvrir les notifications
              },
            ),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // Action pour ouvrir le menu
              },
            ),
          ],
        ),

        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte pour afficher le solde et le nom de l'utilisateur
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.zero,
                  color: const Color(0xFFEAF6E9),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: greenCustomColor,
                          child: Icon(LucideIcons.wallet2,
                              size: 30, color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحبًا، إيهي', // Nom de l'utilisateur
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Droid',
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
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
                ),
                const SizedBox(height: 20),

                // Boutons d'action interactifs
                Row(
                  children: [
                    Expanded(
                      child: ActionButton(
                        icon: LucideIcons.listOrdered,
                        label: 'انشاء طلبية',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateOrderPage()),
                          );
                        },
                        backgroundColor:
                            Colors.blue.shade50, // Une légère teinte bleue
                        borderColor: Colors.blue.shade200,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ActionButton(
                        icon: LucideIcons.shoppingCart,
                        label: 'عملية شراء',
                        onPressed: () {},
                        backgroundColor: Colors.green[50],
                        borderColor: Colors.green[200],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Autres boutons interactifs
                Row(
                  children: [
                    Expanded(
                      child: ActionButton(
                        icon: LucideIcons.pieChart,
                        label: 'نظرة عامة',
                        onPressed: () {},
                        backgroundColor: Colors.orange.shade50,
                        borderColor: Colors.orange.shade200,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ActionButton(
                        icon: LucideIcons.book,
                        label: 'دفتر الديون',
                        onPressed: () {},
                        backgroundColor: Colors.red.shade50,
                        borderColor: Colors.red.shade200,
                      ),
                    ),
                  ],
                ),

                // Section des favoris
                const SizedBox(height: 20),
                const Text(
                  'أشخاصك المفضلين',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildAddFavoriteButton(),
                    const SizedBox(width: 16),
                    _buildFavoriteCircle('غريس ل.', Colors.pink[200]),
                    const SizedBox(width: 16),
                    _buildFavoriteCircle('لورانس أ.', Colors.blue[200]),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
            CustomBottomNavBar(), // Utilisation du widget séparé
      ),
    );
  }

  Widget _buildAddFavoriteButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(Icons.add, color: Colors.grey[600]),
    );
  }

  Widget _buildFavoriteCircle(String initials, Color? color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Center(
        child: Text(
          initials.split(' ').map((name) => name[0]).join(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
