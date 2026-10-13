import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/theme/app_colors.dart';
import 'package:chat_app/widgets/message_item.dart';
import 'package:chat_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatelessWidget {
  final User contact;

  const ChatScreen({
    super.key,
    required this.contact,
  });

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Hors ligne';
    final hour = lastSeen.hour.toString().padLeft(2, '0');
    final minute = lastSeen.minute.toString().padLeft(2, '0');
    return 'Vu(e) à $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController(contact), tag: contact.id);
    final myId = AuthService.to.currentUser.value?.id ?? 'u_me';

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          Get.delete<ChatController>(tag: contact.id);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: _buildAppBar(controller, context),
        body: Column(
        children: [
          Obx(() {
            if (controller.isBlocked) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.errorContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 8,
                      children: const [
                        Icon(Icons.block, size: 18, color: AppColors.error),
                        Text(
                          'Vous avez bloqué ce contact.',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: controller.toggleBlock,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Débloquer',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          Expanded(
            child: Obx(() {
              final messages = controller.messages;
              final isTyping = controller.isContactTyping;

              if (messages.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: messages.length + 1 + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildDateHeader();
                  }

                  if (isTyping && index == messages.length + 1) {
                    return _buildTypingBubble();
                  }

                  final msg = messages[index - 1];
                  final isMe = msg.senderId == myId;
                  return MessageItem(msg: msg, isMe: isMe, contact: contact);
                },
              );
            }),
          ),

          _buildComposer(controller, context),
        ],
      ),
    ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatController controller, BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 1,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.primary),
        onPressed: () {
          Get.delete<ChatController>(tag: contact.id);
          Get.back();
        },
      ),
      title: Obx(() {
        final isOnline = controller.isContactOnline;
        final isTyping = controller.isContactTyping;
        final lastSeen = controller.contactLastSeen;

        return Row(
          spacing: 12,
          children: [
            UserAvatar(
              name: contact.name,
              size: 40,
              showOnlineIndicator: true,
              isOnline: isOnline,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isTyping)
                    Row(
                      spacing: 4,
                      children: const [
                        Text(
                          'en train d\'écrire...',
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
                    Row(
                      spacing: 4,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isOnline ? AppColors.secondary : AppColors.outlineVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          isOnline ? 'En ligne' : _formatLastSeen(lastSeen),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isOnline ? AppColors.secondary : AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'block') {
              controller.toggleBlock();
            } else if (value == 'info') {
              _showContactDetails(context);
            }
          },
          itemBuilder: (context) {
            final isBlocked = controller.isBlocked;
            return [
              PopupMenuItem(
                value: 'info',
                child: Row(
                  spacing: 8,
                  children: const [
                    Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                    Text('Détails du profil'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(
                      isBlocked ? Icons.lock_open : Icons.block,
                      size: 18,
                      color: isBlocked ? AppColors.primary : AppColors.error,
                    ),
                    Text(
                      isBlocked ? 'Débloquer ce contact' : 'Bloquer ce contact',
                      style: TextStyle(
                        color: isBlocked ? AppColors.primary : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildDateHeader() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: const [
            Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
            Text(
              'Aujourd\'hui',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 8,
        children: [
          UserAvatar(name: contact.name, size: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                _buildDot(0),
                _buildDot(150),
                _buildDot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delayMs) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          UserAvatar(
            name: contact.name,
            size: 64,
          ),
          Text(
            'Démarrer la discussion avec ${contact.name}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const Text(
            'Envoyez un premier message texte pour débuter l\'échange.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(ChatController controller, BuildContext context) {
    return Obx(() {
      final isBlocked = controller.isBlocked;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: 10 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            spacing: 10,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isBlocked ? AppColors.surfaceContainer : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: controller.textController,
                    enabled: !isBlocked,
                    textInputAction: TextInputAction.send,
                    onChanged: controller.onTextChanged,
                    onSubmitted: (_) => controller.sendMessage(),
                    decoration: InputDecoration(
                      hintText: isBlocked
                          ? 'Contact bloqué...'
                          : 'Écrivez votre message...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isBlocked ? AppColors.outlineVariant : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: isBlocked
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: isBlocked ? null : controller.sendMessage,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showContactDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 12,
            children: [
              UserAvatar(
                name: contact.name,
                size: 64,
                showOnlineIndicator: true,
                isOnline: contact.isOnline,
              ),
              Text(
                contact.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                contact.email,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  contact.role,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
