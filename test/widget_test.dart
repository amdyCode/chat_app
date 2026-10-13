import 'package:chat_app/main.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  testWidgets('Chat test', (WidgetTester tester) async {
    Get.put(AuthService(), permanent: true);
    Get.put(ChatService(), permanent: true);

    await tester.pumpWidget(const MainApp());

    expect(find.text('Bienvenue sur Chat'), findsOneWidget);
    expect(find.text('Connexion'), findsWidgets);
  });
}
