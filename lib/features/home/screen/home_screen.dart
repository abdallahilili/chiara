import 'package:chira/features/orders/screens/create_order_page.dart';
import 'package:flutter/material.dart';
import 'package:chira/features/home/widgets/custom_bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          TextDirection.rtl, // Définit la direction du texte de droite à gauche
      child: Scaffold(
        appBar: AppBar(),
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
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue[200],
                          child:
                              Icon(Icons.person, size: 30, color: Colors.white),
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
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '1,234.00',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'أوقية',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
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
                SizedBox(height: 20),

                // Boutons d'action interactifs
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.send,
                        label: ' انشاء طبلية',
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateOrderPage()));
                        },
                        backgroundColor: Colors.white,
                        borderColor: Colors.grey[300],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.call_received,
                        label: 'طلب المال',
                        onPressed: () {},
                        backgroundColor: Colors.green[50],
                        borderColor: Colors.green[100],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Autres boutons interactifs
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.phone_android,
                        label: 'شراء رصيد',
                        onPressed: () {},
                        backgroundColor: Colors.white,
                        borderColor: Colors.grey[300],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.receipt,
                        label: 'دفع الفواتير',
                        onPressed: () {},
                        backgroundColor: Colors.white,
                        borderColor: Colors.grey[300],
                      ),
                    ),
                  ],
                ),

                // Section des favoris
                SizedBox(height: 20),
                Text(
                  'أشخاصك المفضلين',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildAddFavoriteButton(),
                    SizedBox(width: 16),
                    _buildFavoriteCircle('غريس ل.', Colors.pink[200]),
                    SizedBox(width: 16),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color? backgroundColor,
    required Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor ?? Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.black),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
