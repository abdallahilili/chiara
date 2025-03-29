import 'package:chira/common/utils/colors.dart';
import 'package:chira/common/widgets/custom_button.dart';
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
        title: const Text('معلومات المستخدم'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // صورة المستخدم
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

                // حقول الإدخال
                _buildTextField(
                  controller: userController.nameController,
                  hintText: 'أدخل اسمك',
                ),
                _buildTextField(
                  controller: userController.shopIdController,
                  hintText: 'أدخل معرف المتجر',
                ),
                _buildTextField(
                  controller: userController.emailController,
                  hintText: 'أدخل بريدك الإلكتروني',
                ),

                // اختيار نوع المستخدم
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
                            title: 'بائع',
                            value: 'vendeur',
                          ),
                          _buildCustomRadioButton(
                            title: 'مشتري',
                            value: 'acheteur',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // زر المتابعة
                SizedBox(
                  width: size.width * 0.8,
                  child: CustomButton(
                    onPressed: userController.storeUserData,
                    text: 'التالي',
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

  // ودجت لحقل الإدخال
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // ودجت لأزرار الاختيار المخصصة
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
                  ? greenCustomColor
                  : whiteColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: userController.selectedRole.value == value
                      ? greenCustomColor
                      : whiteColor),
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
