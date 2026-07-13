import 'dart:io';
import 'package:flutter/material.dart';

import '../theme/color_schemes.dart';

/// Customer avatar with photo or gradient initials fallback.
///
/// Displays the customer's photo if available, otherwise shows
/// their initials on a gradient background derived from their name.
class CustomerAvatar extends StatelessWidget {
  final String name;
  final String? photoPath;
  final double size;
  final double fontSize;

  const CustomerAvatar({
    super.key,
    required this.name,
    this.photoPath,
    this.size = 48,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final gradient = _getGradient(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: photoPath == null ? gradient : null,
        boxShadow: [
          BoxShadow(
            color: (photoPath == null
                    ? gradient.colors.first
                    : AppColors.primaryLight)
                .withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: photoPath != null && File(photoPath!).existsSync()
          ? Image.file(
              File(photoPath!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildInitials(initials),
            )
          : _buildInitials(initials),
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Generate a deterministic gradient based on the name.
  LinearGradient _getGradient(String name) {
    final hash = name.hashCode;
    final gradients = [
      const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF3F37C9), Color(0xFF0EA5E9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF059669), Color(0xFF0EA5E9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFE11D48), Color(0xFFF97316)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];

    return gradients[hash.abs() % gradients.length];
  }
}
