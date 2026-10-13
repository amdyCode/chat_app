import 'package:chat_app/controllers/home_controller.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/theme/app_colors.dart';
import 'package:chat_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(controller),
            _buildSearchBar(controller),
            _buildFilterPills(controller),
            _buildSectionHeader(controller),
            Expanded(
              child: Obx(() {
                final contacts = controller.filteredContacts;
                if (contacts.isEmpty) {
                  return _buildEmptyState(controller);
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: contacts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return _buildContactCard(controller, contact);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(HomeController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Obx(() {
        final currentUser = AuthService.to.currentUser.value;
        final userName = currentUser?.name ?? 'Utilisateur';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 10,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    const Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Connecté en tant que $userName',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                UserAvatar(
                  name: userName,
                  size: 34,
                  showOnlineIndicator: true,
                  isOnline: true,
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppColors.outline, size: 22),
                  tooltip: 'Déconnexion',
                  onPressed: controller.logout,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchBar(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.outline, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un contact ou une discussion...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.outline,
                  ),
                ),
              ),
            ),
            Obx(() {
              if (controller.searchQuery.value.isNotEmpty) {
                return GestureDetector(
                  onTap: controller.clearSearch,
                  child: const Icon(Icons.close, color: AppColors.outline, size: 18),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPills(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Obx(
        () => Row(
          spacing: 8,
          children: [
            _buildFilterChip(controller, 'all', 'Tous'),
            _buildFilterChip(controller, 'online', 'En ligne'),
            _buildFilterChip(controller, 'recent', 'Récents'),
            _buildFilterChip(controller, 'blocked', 'Bloqués'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(HomeController controller, String key, String label) {
    final isSelected = controller.selectedFilter.value == key;
    return GestureDetector(
      onTap: () => controller.setFilter(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Obx(() {
        final count = controller.filteredContacts.length;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DISCUSSIONS & CONTACTS ($count)',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.outline,
                letterSpacing: 0.8,
              ),
            ),
            const Text(
              'Temps réel',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.outline,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildContactCard(HomeController controller, User contact) {
    return Obx(() {
      final unreadCount = controller.getUnreadCount(contact.id);
      final isTyping = controller.isContactTyping(contact.id);
      final isOnline = controller.isContactOnline(contact.id);
      final isBlocked = AuthService.to.isUserBlocked(contact.id);
      final lastMsg = ChatService.to.getLastMessageForContact(contact.id);

      return InkWell(
        onTap: () => controller.openChat(contact),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            spacing: 12,
            children: [
              UserAvatar(
                name: contact.name,
                size: 48,
                showOnlineIndicator: true,
                isOnline: isOnline,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Row(
                      spacing: 6,
                      children: [
                        Flexible(
                          child: Text(
                            contact.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isBlocked
                                ? AppColors.errorContainer
                                : isOnline
                                    ? AppColors.secondaryContainer.withValues(alpha: 0.3)
                                    : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isBlocked
                                ? 'Bloqué'
                                : isOnline
                                    ? 'En ligne'
                                    : 'Hors ligne',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: isBlocked
                                  ? AppColors.error
                                  : isOnline
                                      ? AppColors.onSecondaryContainer
                                      : AppColors.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      contact.role,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (isTyping)
                      Row(
                        spacing: 4,
                        children: const [
                          Icon(Icons.edit_note, size: 14, color: AppColors.primary),
                          Text(
                            'En train d\'écrire...',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        lastMsg != null ? lastMsg.text : contact.statusMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: lastMsg != null ? AppColors.onSurfaceVariant : AppColors.outline,
                          fontStyle: lastMsg == null ? FontStyle.italic : FontStyle.normal,
                          fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  if (lastMsg != null)
                    Text(
                      '${lastMsg.timestamp.hour.toString().padLeft(2, '0')}:${lastMsg.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isBlocked)
                    const Icon(
                      Icons.block,
                      size: 16,
                      color: AppColors.error,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(HomeController controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: const [
          Icon(Icons.person_search, size: 48, color: AppColors.outline),
          Text(
            'Aucun contact trouvé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            'Essayez un autre mot-clé ou modifiez les filtres.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
