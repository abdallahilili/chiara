import 'package:chira/common/utils/colors.dart';
import 'package:chira/common/widgets/custom_button.dart';
import 'package:chira/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Text(
                  '',
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height / 5),
                SizedBox(
                  width: size.width * 
                      0.8, // Réduit la largeur de l'image à 60% de l'écran
                  child: Image.asset(
                    'assets/imgs/logo_tesshil02.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: size.height / 5),
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'يرجى قراءة سياسة الخصوصية الخاصة بنا. اضغط على "قبول ومتابعة" للموافقة على شروط الاستخدام.',
                    style: TextStyle(color: textColor, fontFamily: 'Droid'),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: 0.75,
                  child: CustomButton(
                    text: 'متابعة',
                    onPressed: () => navigateToLoginScreen(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
