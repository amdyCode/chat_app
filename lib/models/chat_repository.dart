import 'package:chat_app/models/chat_message.dart';
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

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void _initDefaultData() {
    _allUsers.addAll([
      const User(
        id: 'u1',
        name: 'Thomas Leroy',
        email: 'thomas.leroy@chat.io',
        role: 'Développeur Mobile',
        isOnline: true,
        statusMessage: 'Disponible pour un échange technique',
      ),
      const User(
        id: 'u2',
        name: 'Clara Martin',
        email: 'clara.martin@chat.io',
        role: 'Designer UI/UX',
        isOnline: true,
        statusMessage: 'Sur les maquettes de l\'application',
      ),
      const User(
        id: 'u3',
        name: 'Alexandre Petit',
        email: 'alexandre.petit@chat.io',
        role: 'Product Lead',
        isOnline: false,
        statusMessage: 'En réunion client',
      ),
      const User(
        id: 'u4',
        name: 'Sophie Bernard',
        email: 'sophie.bernard@chat.io',
        role: 'Marketing Specialist',
        isOnline: true,
        statusMessage: 'Prête pour la démo',
      ),
      const User(
        id: 'u5',
        name: 'Julien Moreau',
        email: 'julien.moreau@chat.io',
        role: 'Lead Backend',
        isOnline: false,
        statusMessage: 'Vu hier à 19:42',
      ),
    ]);

    // Initial messages with Clara Martin (as seen in Stitch screen 4)
    final now = DateTime.now();
    _messages.addAll([
      ChatMessage(
        id: 'm1',
        senderId: 'u2',
        receiverId: 'u_me',
        text: 'Salut ! Est-ce que tu as pu jeter un œil aux maquettes de la nouvelle version mobile ?',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm2',
        senderId: 'u_me',
        receiverId: 'u2',
        text: 'Oui totalement ! Le rendu est super fluide et moderne. J\'adore les indicateurs de statut en direct.',
        timestamp: now.subtract(const Duration(minutes: 12)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm3',
        senderId: 'u2',
        receiverId: 'u_me',
        text: 'Super ! La version épurée sans les options vocales et vidéo est beaucoup plus directe.',
        timestamp: now.subtract(const Duration(minutes: 8)),
        isRead: true,
      ),
      ChatMessage(
        id: 'm4',
        senderId: 'u_me',
        receiverId: 'u2',
        text: 'C\'est validé de mon côté ! On lance le développement dès aujourd\'hui.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: true,
      ),
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

  List<ChatMessage> getMessagesForUser(String contactId) {
    final myId = _currentUser?.id ?? 'u_me';
    return _messages.where((m) {
      return (m.senderId == myId && m.receiverId == contactId) ||
          (m.senderId == contactId && m.receiverId == myId);
    }).toList();
  }

  ChatMessage? getLastMessage(String contactId) {
    final thread = getMessagesForUser(contactId);
    if (thread.isEmpty) return null;
    return thread.last;
  }

  void sendMessage({required String receiverId, required String text}) {
    if (text.trim().isEmpty) return;
    final myId = _currentUser?.id ?? 'u_me';
    final newMessage = ChatMessage(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      senderId: myId,
      receiverId: receiverId,
      text: text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
    );
    _messages.add(newMessage);
    notifyListeners();
  }
}
