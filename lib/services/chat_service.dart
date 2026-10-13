import 'dart:async';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:get/get.dart';

class ChatService extends GetxService {
  static ChatService get to => Get.find<ChatService>();

  final RxList<Message> messages = <Message>[].obs;

  final RxMap<String, bool> typingStatus = <String, bool>{}.obs;

  final RxMap<String, bool> presenceStatus = <String, bool>{}.obs;

  final RxMap<String, DateTime> lastSeenStatus = <String, DateTime>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initDefaultMessages();
  }

  void _initDefaultMessages() {
    final now = DateTime.now();
    messages.assignAll([
      Message(
        id: 'm1',
        senderId: 'u2', // Clara Martin
        receiverId: 'u_me',
        text: 'Salut ! Est-ce que tu as pu jeter un œil aux maquettes de la nouvelle version mobile ?',
        timestamp: now.subtract(const Duration(minutes: 15)),
        receipt: MessageReceipt.read,
        readAt: now.subtract(const Duration(minutes: 13)),
      ),
      Message(
        id: 'm2',
        senderId: 'u_me',
        receiverId: 'u2',
        text: 'Oui totalement ! Le rendu est super fluide et moderne. J\'adore les indicateurs de statut en direct.',
        timestamp: now.subtract(const Duration(minutes: 12)),
        receipt: MessageReceipt.read,
        readAt: now.subtract(const Duration(minutes: 10)),
      ),
      Message(
        id: 'm3',
        senderId: 'u2',
        receiverId: 'u_me',
        text: 'Super ! La version épurée sans les options vocales et vidéo est beaucoup plus directe.',
        timestamp: now.subtract(const Duration(minutes: 8)),
        receipt: MessageReceipt.read,
        readAt: now.subtract(const Duration(minutes: 6)),
      ),
      Message(
        id: 'm4',
        senderId: 'u_me',
        receiverId: 'u2',
        text: 'C\'est validé de mon côté ! On lance le développement dès aujourd\'hui.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        receipt: MessageReceipt.read,
        readAt: now.subtract(const Duration(minutes: 3)),
      ),
      Message(
        id: 'm5',
        senderId: 'u1', // Thomas Leroy
        receiverId: 'u_me',
        text: 'Hello ! As-tu un moment pour revoir la PR sur les conventions Flutter ?',
        timestamp: now.subtract(const Duration(minutes: 2)),
        receipt: MessageReceipt.delivered,
      ),
    ]);

    // Initial presence
    presenceStatus.addAll({
      'u1': true,
      'u2': true,
      'u3': false,
      'u4': true,
      'u5': false,
    });

    lastSeenStatus.addAll({
      'u3': now.subtract(const Duration(minutes: 25)),
      'u5': now.subtract(const Duration(hours: 3)),
    });
  }

  bool sendMessage({required String receiverId, required String text}) {
    final currentUserId = AuthService.to.currentUser.value?.id ?? 'u_me';

    if (AuthService.to.isUserBlocked(receiverId)) {
      Get.snackbar(
        'Action impossible',
        'Vous avez bloqué ce contact. Débloquez-le pour envoyer un message.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final now = DateTime.now();
    final messageId = 'm_${now.millisecondsSinceEpoch}';

    final newMessage = Message(
      id: messageId,
      senderId: currentUserId,
      receiverId: receiverId,
      text: text.trim(),
      timestamp: now,
      receipt: MessageReceipt.sent,
    );

    messages.add(newMessage);

    Future.delayed(const Duration(milliseconds: 500), () {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1 && messages[index].receipt == MessageReceipt.sent) {
        messages[index] = messages[index].copyWith(
          receipt: MessageReceipt.delivered,
          deliveredAt: DateTime.now(),
        );
      }
    });

    if (receiverId == 'u2') {
      _simulateContactResponse(contactId: 'u2');
    }

    return true;
  }

  void setMyTyping({required String contactId, required bool isTyping}) {
  }

  bool isContactTyping(String contactId) {
    return typingStatus[contactId] ?? false;
  }

  bool isContactOnline(String contactId) {
    return presenceStatus[contactId] ?? false;
  }

  DateTime? getContactLastSeen(String contactId) {
    return lastSeenStatus[contactId];
  }

  void markMessagesAsRead({required String contactId}) {
    final currentUserId = AuthService.to.currentUser.value?.id ?? 'u_me';
    final now = DateTime.now();

    final hasUnread = messages.any((m) =>
        m.senderId == contactId &&
        m.receiverId == currentUserId &&
        m.receipt != MessageReceipt.read);

    if (!hasUnread) return;

    for (int i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (m.senderId == contactId && m.receiverId == currentUserId && m.receipt != MessageReceipt.read) {
        messages[i] = m.copyWith(
          receipt: MessageReceipt.read,
          readAt: now,
        );
      }
    }
  }

  int getUnreadCount(String contactId) {
    final currentUserId = AuthService.to.currentUser.value?.id ?? 'u_me';
    return messages.where((m) {
      return m.senderId == contactId &&
          m.receiverId == currentUserId &&
          m.receipt != MessageReceipt.read;
    }).length;
  }

  int getTotalUnreadCount() {
    final currentUserId = AuthService.to.currentUser.value?.id ?? 'u_me';
    return messages.where((m) {
      return m.receiverId == currentUserId && m.receipt != MessageReceipt.read;
    }).length;
  }

  List<Message> getMessagesForContact(String contactId) {
    final currentUserId = AuthService.to.currentUser.value?.id ?? 'u_me';
    return messages.where((m) {
      return (m.senderId == currentUserId && m.receiverId == contactId) ||
          (m.senderId == contactId && m.receiverId == currentUserId);
    }).toList();
  }

  Message? getLastMessageForContact(String contactId) {
    final thread = getMessagesForContact(contactId);
    if (thread.isEmpty) return null;
    return thread.last;
  }

  void _simulateContactResponse({required String contactId}) {
    Future.delayed(const Duration(seconds: 1), () {
      final currentUserId = AuthService.to.currentUser.value?.id ?? 'u_me';
      for (int i = 0; i < messages.length; i++) {
        final m = messages[i];
        if (m.senderId == currentUserId && m.receiverId == contactId && m.receipt != MessageReceipt.read) {
          messages[i] = m.copyWith(receipt: MessageReceipt.read, readAt: DateTime.now());
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      typingStatus[contactId] = true;
    });

    Future.delayed(const Duration(milliseconds: 3800), () {
      typingStatus[contactId] = false;

      final currentUserId = AuthService.to.currentUser.value?.id ?? 'u_me';
      final responseMsg = Message(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        senderId: contactId,
        receiverId: currentUserId,
        text: 'Bien reçu !',
        timestamp: DateTime.now(),
        receipt: MessageReceipt.delivered,
      );

      messages.add(responseMsg);
    });
  }
}
