import 'package:chira/features/auth/repository/auth_repository.dart';
import 'package:chira/features/orders/screens/create_order_page.dart';
import 'package:chira/features/purchases/widgets/purchase_type_dialog.dart';
import 'package:flutter/material.dart';
import 'package:chira/features/home/widgets/custom_bottom_nav_bar.dart';
import 'package:chira/models/user_model.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chira/features/home/widgets/balance_card_widget.dart';
import 'package:chira/features/home/widgets/action_buttons_section.dart';
import 'package:chira/features/home/widgets/favorites_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? currentUser;
  bool isLoading = true;

  final AuthRepository _authRepository = AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authRepository.getUserData();
      setState(() {
        currentUser = userData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        "Erreur",
        "Impossible de charger les données utilisateur: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          TextDirection.rtl, // Définit la direction du texte de droite à gauche
      child: Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: Colors.white,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carte pour afficher le solde et le nom de l'utilisateur
                        BalanceCardWidget(userName: currentUser?.name),
                        const SizedBox(height: 20),

                        // Sections des boutons d'action
                        ActionButtonsSection(
                          onCreateOrderPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateOrderPage()),
                            );
                          },
                          onPurchasePressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const PurchaseTypeDialog(),
                            );
                          },
                        ),

                        // Section des favoris
                        const SizedBox(height: 20),
                        const FavoritesSection(),

                        // Espace pour éviter que le contenu soit caché par la barre de navigation
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: CustomBottomNavBar(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
    );
  }
}
