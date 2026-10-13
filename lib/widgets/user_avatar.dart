import 'package:chat_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final bool showOnlineIndicator;
  final bool isOnline;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 46,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.backgroundColor,
  });

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.getAvatarColor(name);
    final indicatorSize = (size * 0.28).clamp(9.0, 14.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: bg.withValues(alpha: 0.28),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            _initial,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.44,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: indicatorSize,
              height: indicatorSize,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.secondary : AppColors.outlineVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surfaceContainerLowest,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
