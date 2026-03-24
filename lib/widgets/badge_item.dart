import 'package:flutter/material.dart';
import '../models/badge_model.dart';

class BadgeItem extends StatelessWidget {
  final BadgeModel badge;

  const BadgeItem({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: badge.isUnlocked ? badge.name : "Bloqueado: Continue treinando!",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: badge.isUnlocked
                  ? LinearGradient(colors: badge.gradientColors)
                  : null,
              color: badge.isUnlocked ? null : Colors.white.withOpacity(0.05),
            ),
            alignment: Alignment.center,
            child: Opacity(
              opacity: badge.isUnlocked ? 1.0 : 0.2,
              child: Text(badge.icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.name.split(' ')[0],
            style: TextStyle(
              color: badge.isUnlocked ? Colors.white70 : Colors.white24,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
