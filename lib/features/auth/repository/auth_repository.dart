import 'dart:io';

// import 'package:chat_app/common/repositories/supabase_storage_repository.dart';
// import 'package:chat_app/common/utils/utils.dart';
// import 'package:chat_app/features/auth/screens/otp_screen.dart';
// import 'package:chat_app/features/auth/screens/user_information_screen.dart';
// import 'package:chat_app/models/user_model.dart';
// import 'package:chat_app/screens/mobile_layout_screen.dart';
import 'package:chira/common/repositories/supabase_storage_repository.dart';
import 'package:chira/features/auth/screens/otp_screen.dart';
import 'package:chira/features/auth/screens/user_information_screen.dart';
import 'package:chira/features/home/screen/home_screen.dart';
import 'package:chira/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  void signInWithPhone(String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          print(e.message);
          Get.snackbar("Erreur", e.message ?? "Une erreur s'est produite",
              backgroundColor: Colors.red, colorText: Colors.white);
        },
        codeSent: ((String verificationId, int? resendToken) async {
          Get.toNamed(
            OTPScreen.routeName,
            arguments: verificationId,
          );
        }),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      Get.snackbar("Erreur", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void verifyOTP({
    required String verificationId,
    required String userOTP,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );

      await auth.signInWithCredential(credential);
      Get.offAllNamed(UserInformationScreen.routeName);
    } on FirebaseAuthException catch (e) {
      print(e.message);
      Get.snackbar("Erreur", e.message ?? "Code OTP invalide",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> saveUserDataToFirebase({
    required String name,
    required String shopId,
    required String email,
    required File? profilePic,
    required String role,
  }) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw Exception("Utilisateur non authentifié");
      }

      String uid = user.uid;

      // Obtenir le token FCM
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // URL de l'image de profil par défaut
      String photoUrl =
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

      if (profilePic != null) {
        final supabaseRepository = SupabaseStorageRepository();

        photoUrl = await supabaseRepository.uploadImageToSupabase(
          'chira-app', // 🔹 Remplace par le nom de ton bucket
          'images_profile/$uid',
          profilePic,
        );
      }

      // Création de l'objet utilisateur
      var userModel = UserModel(
        name: name,
        uid: uid,
        shopId: shopId,
        email: email,
        profilePic: photoUrl,
        isActive: true,
        phoneNumber: user.phoneNumber.toString(),
        role: role,
        jobType: 'vendeur', // 🔹 Ajout du type de travail
        createdAt: DateTime.now(),
        fcmToken: fcmToken, // 🔹 Ajout du token FCM
      );

      // Enregistrement dans Firestore
      await firestore.collection('users').doc(uid).set(userModel.toMap());
      Get.offAll(() => HomePage()); // Ajoute une navigation à l'écran d'accueil
    } catch (e) {
      Get.snackbar("Erreur", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> updateFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null && auth.currentUser != null) {
      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'fcmToken': token,
      });
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      String uid = auth.currentUser!.uid;
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Vérifie la présence du fcmToken et de l'image de profil
        userData['fcmToken'] ??= null;
        userData['profilePic'] ??=
            'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

        return UserModel.fromMap(userData);
      }
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur : $e');
    }
    return null;
  }

  Stream<UserModel> userData(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(
            event.data()!,
          ),
        );
  }

  void setUserState(bool isOnline) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'isOnline': isOnline,
    });
  }
}
