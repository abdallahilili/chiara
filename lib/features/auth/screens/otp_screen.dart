import 'package:chira/common/utils/colors.dart';
import 'package:chira/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OTPScreen extends StatelessWidget {
  static const String routeName = '/otp-screen';
  final String verificationId;

  OTPScreen({super.key, required this.verificationId});

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final AuthController authController = Get.find<AuthController>();

  void verifyOTP() {
    final otpCode = _controllers.map((c) => c.text).join();
    if (otpCode.length == 6) {
      authController.verifyOTP(verificationId, otpCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Entrez votre code OTP',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Un code à 6 chiffres a été envoyé à votre numéro.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: size.width * 0.12,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && index < 5) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index + 1]);
                        } else if (val.isEmpty && index > 0) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index - 1]);
                        }

                        if (_controllers.every((c) => c.text.isNotEmpty)) {
                          verifyOTP();
                        }
                      },
                      onSubmitted: (_) => verifyOTP(),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Obx(() => TextButton(
                    onPressed: authController.remainingSeconds.value == 0
                        ? authController.resendCode
                        : null,
                    child: Text(
                      'Renvoyer le code',
                      style: TextStyle(
                        color: authController.remainingSeconds.value == 0
                            ? Colors.blue
                            : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )),
              const SizedBox(height: 10),
              Obx(() => LinearProgressIndicator(
                    value: authController.remainingSeconds.value / 300,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.green),
                  )),
              const SizedBox(height: 10),
              Obx(() => Text(
                    '${authController.remainingSeconds.value ~/ 60}:${(authController.remainingSeconds.value % 60).toString().padLeft(2, '0')} restantes',
                    style: const TextStyle(fontSize: 16, color: tabColor),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
