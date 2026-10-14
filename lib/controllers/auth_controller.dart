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
    emailController = TextEditingController();
    passwordController = TextEditingController();
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

  Future<void> sendPasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar(
        'Email requis',
        'Veuillez saisir une adresse email valide ci-dessus.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await AuthService.to.sendPasswordResetEmail(email);
      Get.snackbar(
        'Email envoyé',
        'Un lien de réinitialisation vous a été envoyé à $email.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
