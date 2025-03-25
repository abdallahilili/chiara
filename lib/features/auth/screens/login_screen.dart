import 'package:chira/common/utils/colors.dart';
import 'package:chira/common/widgets/custom_button.dart';
import 'package:chira/features/auth/controller/auth_controller.dart';
import 'package:chira/features/auth/repository/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login-screen';

  final TextEditingController phoneController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // L'injection des dépendances via GetX
  final AuthRepository authRepository = Get.put(
    AuthRepository(
        auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance),
  );

  final AuthController authController = Get.put(AuthController(
      authRepository: AuthRepository(
          auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance)));
  final Rx<Country?> country = Rx<Country?>(null);

  LoginScreen({super.key}) {
    // Définir la valeur par défaut du pays à Mauritanie (+222)
    country.value = Country(
      phoneCode: '222',
      countryCode: 'MR',
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: 'Mauritania',
      example: '22123456',
      displayName: 'Mauritania',
      displayNameNoCountryCode: 'Mauritania',
      e164Key: '222-MR-0',
    );
  }

  void pickCountry() {
    showCountryPicker(
      context: Get.context!,
      showPhoneCode: true,
      onSelect: (Country selectedCountry) {
        country.value = selectedCountry;
      },
    );
  }

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();
    print('phoneNumber kkllk: $phoneNumber');
    print(' country : ${country.value?.phoneCode}');

    if (country.value != null) {
      print(
          ' country appres selection de country : ${country.value!.phoneCode}');
      // Updated call without context
      authController.signInWithPhone(
        '+${country.value!.phoneCode}$phoneNumber',
      );
    } else {
      // Updated to use GetX snackbar
      Get.snackbar('Erreur', 'Veuillez choisir un pays');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Bienvenue sur EduChat !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 17, 17, 226),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                'Veuillez entrer votre numéro de téléphone pour commencer.',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => TextButton(
                        onPressed: pickCountry,
                        child: Row(
                          children: [
                            Text(
                              '+${country.value?.phoneCode ?? '222'}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 44, 44, 233)),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                          color: const Color.fromARGB(255, 51, 51, 180)),
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Numéro de téléphone',
                        hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 24, 24, 255)
                                .withOpacity(0.5)),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: tabColor, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: appBarColor, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: size.width * 0.9,
                child: CustomButton(
                  onPressed: sendPhoneNumber,
                  text: 'SUIVANT',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'En continuant, vous acceptez nos conditions générales d’utilisation.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 1, 1, 2),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Image.asset(
                'assets/imgs/illu_phone.png',
                height: size.height * 0.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
