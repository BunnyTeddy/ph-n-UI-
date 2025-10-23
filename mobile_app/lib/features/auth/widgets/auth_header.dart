import 'package:flutter/material.dart';

/// Auth Header Widget - Assigned to: Hoàng Chí Bằng
/// Header section for auth screens with logo and title
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.emoji = '🌱',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo/Emoji
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Title
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


