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

}
