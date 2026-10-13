import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final isLogin = true.obs;
  final obscurePassword = true.obs;
  final rememberMe = true.obs;
  final isLoading = false.obs;

  final formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController nameController;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController(text: 'camille.rousseau@chat.io');
    passwordController = TextEditingController(text: 'motdepasse123');
    nameController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }

  void toggleAuthMode(bool loginMode) {
    if (isLogin.value != loginMode) {
      isLogin.value = loginMode;
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      if (isLogin.value) {
        await AuthService.to.login(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        await AuthService.to.register(
          email: emailController.text,
          password: passwordController.text,
          fullName: nameController.text,
        );
      }

      Get.offAll(() => const HomeScreen());
    } catch (e) {
      Get.snackbar(
        'Erreur d\'authentification',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
