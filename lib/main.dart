import 'package:chira/common/utils/colors.dart';
import 'package:chira/features/auth/controller/auth_controller.dart';
import 'package:chira/features/auth/repository/auth_repository.dart';
import 'package:chira/features/home/screen/home_screen.dart';
import 'package:chira/firebase_options.dart';
import 'package:chira/landing/screens/landing_screen.dart';
import 'package:chira/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://yijjdzycfkockqfslpzr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlpampkenljZmtvY2txZnNscHpyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNTg1MDk1OSwiZXhwIjoyMDUxNDI2OTU5fQ.U4bNxuln_nFI_PcKtA3oZYKKh4WJprMEw2yPQdWYjU4',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: greenCustomColor),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: const AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // L'injection des dépendances via GetX
    final AuthController authController = Get.put(AuthController(
        authRepository: AuthRepository(
            auth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance)));

    return Obx(() {
      // Vérifie si l'utilisateur est connecté
      if (authController.currentUser.value != null) {
        // Si l'utilisateur est connecté, afficher la page d'accueil
        return HomePage();
      } else {
        // Sinon, afficher l'écran de lancement
        return const LandingScreen();
      }
    });
  }
}
