import 'dart:io';

import 'package:chira/features/auth/repository/auth_repository.dart';
import 'package:chira/models/user_model.dart';
 import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;
  AuthController({required this.authRepository});

  // Utilisation de variables réactives avec GetX
  var currentUser = Rx<UserModel?>(null);
  var isLoading = false.obs;
  var remainingSeconds = 300.obs; // 5 minutes

  @override
  void onInit() {
    super.onInit();
    fetchUserData(); // Charger les données de l'utilisateur dès l'initialisation
  }

void signInWithPhone(String phoneNumber) {
    authRepository.signInWithPhone(phoneNumber);
  }

  void verifyOTP(String verificationId, String userOTP) {
    authRepository.verifyOTP(
      verificationId: verificationId,
      userOTP: userOTP,
    );
  }

  saveUserDataToFirebase(String name, String matricule, String email,
      File? profilePic, String role) async {
    isLoading.value = true;
    await authRepository.saveUserDataToFirebase(
      name: name,
      matricule: matricule,
      email: email,
      profilePic: profilePic,
      role: role,
    );
    isLoading.value = false;
    fetchUserData(); // Mise à jour des données utilisateur après l'enregistrement
  }

  Future<void> fetchUserData() async {
    UserModel? user = await authRepository.getUserData();
    currentUser.value = user;
  }

  Stream<UserModel> userDataById(String userId) {
    return authRepository.userData(userId);
  }

//getUserData()
  Future<UserModel?> getUserData() {
    return authRepository.getUserData();
  }

  void setUserState(bool isOnline) {
    authRepository.setUserState(isOnline);
  }

  //// autres methodes :
  void startTimer() {}

  void resendCode() {
    remainingSeconds.value = 300; // Réinitialiser à 5 minutes
    startTimer();
    // Ajouter la logique pour renvoyer le code OTP
  }
}
