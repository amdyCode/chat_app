import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  testWidgets('AuthScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.lightTheme, home: const AuthScreen()),
    );

    expect(find.text('Bienvenue sur Chat'), findsOneWidget);
    expect(find.text('Connexion'), findsWidgets);
  });
}
