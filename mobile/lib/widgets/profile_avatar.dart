import 'package:flutter/material.dart';

/// Smart profile avatar that displays:
/// - Profile photo if available
/// - User initials as fallback
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color backgroundColor;
  final Color textColor;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 48,
    this.backgroundColor = const Color(0xFF613EEA),
    this.textColor = Colors.white,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    
    return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(color: Colors.white, width: 2),
        image: imageUrl != null && imageUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? Center(
              child: Text(
                _getInitials(name),
                style: TextStyle(
                  color: textColor,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
    );
  }
}
