import 'package:chat_app/models/chat_message.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/theme/app_colors.dart';
import 'package:chat_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class MessageItem extends StatefulWidget {
  final ChatMessage msg;
  final bool isMe;
  final User contact;
  const MessageItem({super.key, required this.msg, required this.isMe, required this.contact});

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 8,
        children: [
          if (!widget.isMe)
            UserAvatar(
              name: widget.contact.name,
              size: 28,
            ),

          Flexible(
            child: Column(
              crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.isMe ? AppColors.primary : AppColors.surfaceContainerLowest,
                    gradient: widget.isMe
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryContainer],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: widget.isMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: widget.isMe ? const Radius.circular(4) : const Radius.circular(16),
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
                    widget.msg.text,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.35,
                      color: widget.isMe ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                ),

                // Time and status checkmark
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Text(
                        _formatTime(widget.msg.timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.outline,
                        ),
                      ),
                      if (widget.isMe)
                        const Icon(
                          Icons.done_all,
                          size: 14,
                          color: AppColors.primary,
                        ),
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