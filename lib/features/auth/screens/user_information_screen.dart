import 'package:chira/features/auth/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserInformationScreen extends StatelessWidget {
  static const String routeName = '/informations-utilisateur';

  final UserController userController = Get.put(UserController());

  UserInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations Utilisateur'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Image utilisateur
                Obx(() => Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: userController.image.value != null
                              ? FileImage(userController.image.value!)
                              : userController.userProfilePic.value != null
                                  ? NetworkImage(
                                      userController.userProfilePic.value!)
                                  : const NetworkImage(
                                      'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                                    ) as ImageProvider,
                          radius: 64,
                        ),
                        Positioned(
                          bottom: -10,
                          left: 80,
                          child: IconButton(
                            onPressed: userController.selectImage,
                            icon: const Icon(Icons.add_a_photo),
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 20),

                // Champs de saisie
                _buildTextField(
                  controller: userController.nameController,
                  hintText: 'Entrez votre nom',
                ),
                _buildTextField(
                  controller: userController.matriculeController,
                  hintText: 'Entrez votre matricule',
                ),
                _buildTextField(
                  controller: userController.emailController,
                  hintText: 'Entrez votre email',
                ),

                // Sélection du rôle utilisateur
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCustomRadioButton(
                            title: 'Professeur',
                            value: 'Professeur',
                          ),
                          _buildCustomRadioButton(
                            title: 'Étudiant',
                            value: 'Étudiant',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Bouton de soumission
                SizedBox(
                  width: size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: userController.storeUserData,
                    child: const Text('SUIVANT'),
                  ),
                ),

                SizedBox(height: size.height * 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour les champs de saisie
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // Widget pour les boutons radio personnalisés
  Widget _buildCustomRadioButton({
    required String title,
    required String value,
  }) {
    return Obx(() => InkWell(
          onTap: () {
            userController.selectedRole.value = value;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: userController.selectedRole.value == value
                  ? Colors.blue
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: userController.selectedRole.value == value
                    ? Colors.blue
                    : Colors.grey,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  userController.selectedRole.value == value
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: userController.selectedRole.value == value
                      ? Colors.white
                      : Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: userController.selectedRole.value == value
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
