import 'dart:io';
import 'package:chira/features/auth/controller/auth_controller.dart';
import 'package:chira/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserController extends GetxController {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  var nameController = TextEditingController();
  var matriculeController = TextEditingController();
  var emailController = TextEditingController();

  var image = Rx<File?>(null);
  var userProfilePic = Rx<String?>(null);
  var selectedRole = Rx<String?>(null);
  var user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  /// Récupération des données utilisateur depuis Firestore
  Future<void> fetchUserData() async {
    // Remplace par ton propre service Firebase
    final fetchedUser = await Get.find<AuthController>().getUserData();

    if (fetchedUser != null) {
      user.value = fetchedUser;
      nameController.text = user.value!.name;
      matriculeController.text = user.value!.matricule;
      emailController.text = user.value!.email;
      selectedRole.value = user.value!.role;
      userProfilePic.value =
          user.value!.profilePic.isNotEmpty ? user.value!.profilePic : null;
    }
  }

  /// Sélectionner une image depuis la galerie
  Future<void> selectImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image.value = File(pickedImage.path);
    }
  }

  /// Sauvegarde des données utilisateur dans Firebase
  Future<void> storeUserData() async {
    String name = nameController.text.trim();
    String matricule = matriculeController.text.trim();
    String email = emailController.text.trim();

    if (name.isNotEmpty &&
        matricule.isNotEmpty &&
        email.isNotEmpty &&
        selectedRole.value != null) {
      await Get.find<AuthController>().saveUserDataToFirebase(
        name,
        matricule,
        email,
        image.value,
        selectedRole.value!,
      );
      Get.snackbar('Succès', 'Données enregistrées avec succès');
    } else {
      Get.snackbar('Erreur', 'Veuillez remplir tous les champs');
    }
  }
}
