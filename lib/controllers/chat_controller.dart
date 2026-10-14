import 'dart:async';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final User contact;
  ChatController(this.contact);

  late final TextEditingController textController;
  late final ScrollController scrollController;

  Timer? _typingDebounce;
  Worker? _messageWorker;

  @override
  void onInit() {
    super.onInit();
    textController = TextEditingController();
    scrollController = ScrollController();

    ChatService.to.bindMessagesForContact(contact.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ChatService.to.markMessagesAsRead(contactId: contact.id);
      _scrollToBottom();
    });

    _messageWorker = ever(ChatService.to.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ChatService.to.markMessagesAsRead(contactId: contact.id);
        _scrollToBottom();
      });
    });
  }

  @override
  void onClose() {
    ChatService.to.unbindMessagesForContact(contact.id);
    _typingDebounce?.cancel();
    _messageWorker?.dispose();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  List<Message> get messages {
    return ChatService.to.getMessagesForContact(contact.id);
  }

  bool get isContactTyping {
    return ChatService.to.isContactTyping(contact.id);
  }

  bool get isContactOnline {
    return ChatService.to.isContactOnline(contact.id);
  }

  DateTime? get contactLastSeen {
    return ChatService.to.getContactLastSeen(contact.id) ?? contact.lastSeen;
  }

  bool get isBlocked {
    return AuthService.to.isUserBlocked(contact.id);
  }

  void onTextChanged(String text) {
    if (text.trim().isNotEmpty) {
      ChatService.to.setMyTyping(contactId: contact.id, isTyping: true);
      _typingDebounce?.cancel();
      _typingDebounce = Timer(const Duration(milliseconds: 1500), () {
        ChatService.to.setMyTyping(contactId: contact.id, isTyping: false);
      });
    } else {
      ChatService.to.setMyTyping(contactId: contact.id, isTyping: false);
    }
  }

  void sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    textController.clear();
    ChatService.to.setMyTyping(contactId: contact.id, isTyping: false);

    final sent = await ChatService.to.sendMessage(
      receiverId: contact.id,
      text: text,
    );

    if (sent) {
      _scrollToBottom();
    }
  }

  void toggleBlock() {
    final wasBlocked = isBlocked;
    AuthService.to.toggleBlockUser(contact.id);

    Get.snackbar(
      wasBlocked ? 'Contact débloqué' : 'Contact bloqué',
      wasBlocked
          ? 'Vous pouvez à nouveau échanger avec ${contact.name}.'
          : '${contact.name} a été bloqué(e). Les messages ne seront plus envoyés.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }
}
