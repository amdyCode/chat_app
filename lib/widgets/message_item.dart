import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/theme/app_colors.dart';
import 'package:chat_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class MessageItem extends StatelessWidget {
  final Message msg;
  final bool isMe;
  final User contact;

  const MessageItem({
    super.key,
    required this.msg,
    required this.isMe,
    required this.contact,
  });

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildReceiptIcon() {
    switch (msg.receipt) {
      case MessageReceipt.sending:
        return const Icon(
          Icons.access_time_rounded,
          size: 13,
          color: AppColors.outline,
        );
      case MessageReceipt.sent:
        return const Icon(
          Icons.done,
          size: 14,
          color: AppColors.outline,
        );
      case MessageReceipt.delivered:
        return const Icon(
          Icons.done_all,
          size: 14,
          color: AppColors.outline,
        );
      case MessageReceipt.read:
        return const Icon(
          Icons.done_all,
          size: 14,
          color: AppColors.primary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 8,
        children: [
          if (!isMe)
            UserAvatar(
              name: contact.name,
              size: 28,
            ),

          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : AppColors.surfaceContainerLowest,
                    gradient: isMe
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryContainer],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.35,
                      color: isMe ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Text(
                        _formatTime(msg.timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.outline,
                        ),
                      ),
                      if (isMe) _buildReceiptIcon(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}