import 'package:chira/common/utils/colors.dart';
import 'package:chira/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OTPScreen extends StatelessWidget {
  static const String routeName = '/otp-screen';
  final String verificationId;

  OTPScreen({super.key, required this.verificationId});

  final TextEditingController _otpController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  void verifyOTP() {
    final otpCode = _otpController.text.trim();
    if (otpCode.length == 6) {
      authController.verifyOTP(verificationId, otpCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'تحقق من رمز التحقق',
          style: TextStyle(fontFamily: 'Droid', fontSize: 16),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                ' رمز التحقق OTP',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Droid',
                    color: tabColor),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),
              const Text(
                'تم إرسال رمز مكون من 6 أرقام إلى رقم هاتفك.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _otpController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'أدخل رمز التحقق هنا',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (val) {
                  if (val.length == 6) {
                    verifyOTP();
                  }
                },
                onSubmitted: (_) => verifyOTP(),
              ),
              const SizedBox(height: 20),
              Obx(() => TextButton(
                    onPressed: authController.remainingSeconds.value == 0
                        ? authController.resendCode
                        : null,
                    child: Text(
                      'إعادة إرسال الرمز',
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
                    '${authController.remainingSeconds.value ~/ 60}:${(authController.remainingSeconds.value % 60).toString().padLeft(2, '0')} ثانية متبقية',
                    style: const TextStyle(fontSize: 16, color: tabColor),
                  )),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
