import 'package:chat_app/models/user.dart';
import 'package:flutter/foundation.dart';

class ChatRepository extends ChangeNotifier {

  static final ChatRepository _instance = ChatRepository._internal();
  factory ChatRepository() => _instance;
  ChatRepository._internal() {
    _initDefaultData();
  }

  User? _currentUser;
  User? get currentUser => _currentUser;

  final List<User> _allUsers = [];
  List<User> get allUsers => List.unmodifiable(_allUsers);

  // List of other users authenticated to the app
  List<User> get availableContacts {
    if (_currentUser == null) return List.unmodifiable(_allUsers);
    return _allUsers.where((u) => u.id != _currentUser!.id).toList();
  }

  void _initDefaultData() {
    _allUsers.addAll([
    ]);
  }

  // Authentication: email/password simulation
  bool authenticate({
    required String email,
    required String password,
    String? fullName,
    bool isRegister = false,
  }) {
    if (email.trim().isEmpty || password.length < 6) {
      return false;
    }

    if (isRegister) {
      final name = (fullName != null && fullName.trim().isNotEmpty)
          ? fullName.trim()
          : email.split('@').first;
      final newUser = User(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email.trim(),
        role: 'Membre actif',
        isOnline: true,
        statusMessage: 'Connecté(e)',
      );
      _allUsers.insert(0, newUser);
      _currentUser = newUser;
    } else {
      final existing = _allUsers.cast<User?>().firstWhere(
            (u) => u?.email.toLowerCase() == email.trim().toLowerCase(),
            orElse: () => null,
          );
      if (existing != null) {
        _currentUser = existing;
      } else {
        _currentUser = User(
          id: 'u_me',
          name: email.split('@').first,
          email: email.trim(),
          role: 'Membre actif',
          isOnline: true,
          statusMessage: 'En ligne',
        );
      }
    }

    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
