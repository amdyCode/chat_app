import 'package:chat_app/models/user.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final Rxn<User> currentUser = Rxn<User>();
  final RxList<User> users = <User>[].obs;

  bool get isAuthenticated => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    _initDemoUsers();
  }

  void _initDemoUsers() {
    final now = DateTime.now();
    users.assignAll([
      User(
        id: 'u1',
        name: 'Thomas Leroy',
        email: 'thomas.leroy@chat.io',
        role: 'Développeur Mobile',
        isOnline: true,
        lastSeen: now,
        statusMessage: 'Disponible pour un échange technique',
      ),
      User(
        id: 'u2',
        name: 'Clara Martin',
        email: 'clara.martin@chat.io',
        role: 'Designer UI/UX',
        isOnline: true,
        lastSeen: now,
        statusMessage: 'Sur les maquettes de l\'application',
      ),
      User(
        id: 'u3',
        name: 'Alexandre Petit',
        email: 'alexandre.petit@chat.io',
        role: 'Product Lead',
        isOnline: false,
        lastSeen: now.subtract(const Duration(minutes: 25)),
        statusMessage: 'En réunion client',
      ),
      User(
        id: 'u4',
        name: 'Sophie Bernard',
        email: 'sophie.bernard@chat.io',
        role: 'Marketing Specialist',
        isOnline: true,
        lastSeen: now,
        statusMessage: 'Prête pour la démo',
      ),
      User(
        id: 'u5',
        name: 'Julien Moreau',
        email: 'julien.moreau@chat.io',
        role: 'Lead Backend',
        isOnline: false,
        lastSeen: now.subtract(const Duration(hours: 3)),
        statusMessage: 'Vu hier à 19:42',
      ),
    ]);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final trimmedEmail = email.trim().toLowerCase();
    final existingUser = users.firstWhereOrNull(
      (u) => u.email.toLowerCase() == trimmedEmail,
    );

    if (existingUser != null) {
      currentUser.value = existingUser;
    } else {
      final newUser = User(
        id: 'u_me',
        name: email.split('@').first,
        email: email.trim(),
        role: 'Membre actif',
        isOnline: true,
        lastSeen: DateTime.now(),
        statusMessage: 'En ligne',
      );
      currentUser.value = newUser;
    }

    return true;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newUser = User(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: fullName.trim().isNotEmpty ? fullName.trim() : email.split('@').first,
      email: email.trim(),
      role: 'Membre actif',
      isOnline: true,
      lastSeen: DateTime.now(),
      statusMessage: 'Connecté(e)',
    );

    users.insert(0, newUser);
    currentUser.value = newUser;
    return true;
  }

  Future<void> logout() async {
    currentUser.value = null;
  }

  void toggleBlockUser(String targetUserId) {
    if (currentUser.value == null) return;

    final blocked = List<String>.from(currentUser.value!.blockedUserIds);
    if (blocked.contains(targetUserId)) {
      blocked.remove(targetUserId);
    } else {
      blocked.add(targetUserId);
    }

    currentUser.value = currentUser.value!.copyWith(blockedUserIds: blocked);
  }

  bool isUserBlocked(String userId) {
    return currentUser.value?.isUserBlocked(userId) ?? false;
  }
}
