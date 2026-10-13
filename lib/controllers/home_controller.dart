import 'package:chat_app/models/user.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final searchQuery = ''.obs;
  final selectedFilter = 'all'.obs; // 'all', 'online', 'recent', 'blocked'

  late final TextEditingController searchController;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  List<User> get filteredContacts {
    final myId = AuthService.to.currentUser.value?.id ?? 'u_me';
    final query = searchQuery.value.trim().toLowerCase();
    final allUsers = AuthService.to.users.where((u) => u.id != myId).toList();

    return allUsers.where((user) {
      final matchesQuery = query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);

      final isBlocked = AuthService.to.isUserBlocked(user.id);
      final isOnline = ChatService.to.isContactOnline(user.id) || user.isOnline;
      final hasRecent = ChatService.to.getLastMessageForContact(user.id) != null;

      bool matchesFilter = true;
      if (selectedFilter.value == 'online') {
        matchesFilter = isOnline && !isBlocked;
      } else if (selectedFilter.value == 'recent') {
        matchesFilter = hasRecent && !isBlocked;
      } else if (selectedFilter.value == 'blocked') {
        matchesFilter = isBlocked;
      } else {
        matchesFilter = !isBlocked;
      }

      return matchesQuery && matchesFilter;
    }).toList();
  }

  int getUnreadCount(String contactId) {
    return ChatService.to.getUnreadCount(contactId);
  }

  bool isContactTyping(String contactId) {
    return ChatService.to.isContactTyping(contactId);
  }

  bool isContactOnline(String contactId) {
    return ChatService.to.isContactOnline(contactId);
  }

  void openChat(User contact) {
    Get.to(() => ChatScreen(contact: contact));
  }

  void toggleBlock(User contact) {
    final wasBlocked = AuthService.to.isUserBlocked(contact.id);
    AuthService.to.toggleBlockUser(contact.id);

    Get.snackbar(
      wasBlocked ? 'Contact débloqué' : 'Contact bloqué',
      wasBlocked
          ? '${contact.name} a été débloqué(e).'
          : '${contact.name} a été bloqué(e).',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> logout() async {
    await AuthService.to.logout();
    Get.offAll(() => const AuthScreen());
  }
}
