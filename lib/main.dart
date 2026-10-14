import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = Get.put(AuthService(), permanent: true);
  Get.put(ChatService(), permanent: true);

  runApp(MainApp(isLoggedIn: authService.isAuthenticated));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  const MainApp({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const HomeScreen() : const AuthScreen(),
    );
  }
}
