import 'package:flutter/material.dart';
import '../models/badge_model.dart';

class BadgeDetailDialog extends StatelessWidget {
  final BadgeModel badge;

  const BadgeDetailDialog({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: badge.isUnlocked
                  ? LinearGradient(colors: badge.gradientColors)
                  : null,
              color: badge.isUnlocked ? null : Colors.white.withOpacity(0.05),
            ),
            alignment: Alignment.center,
            child: Opacity(
              opacity: badge.isUnlocked ? 1.0 : 0.3,
              child: Text(badge.icon, style: const TextStyle(fontSize: 50)),
            ),
          ),
          const SizedBox(height: 20),

          // Nome e Raridade
          Text(
            badge.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            badge.rarity.toString().split('.').last.toUpperCase(),
            style: TextStyle(
              color: badge.gradientColors.first.withOpacity(0.7),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),

          // REQUISITO (Descrição)
          Text(
            badge.requisito,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          // Status
          if (!badge.isUnlocked)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, color: Colors.white38, size: 16),
                SizedBox(width: 4),
                Text(
                  "Bloqueado: Continue treinando!",
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "FECHAR",
            style: TextStyle(color: Color(0xFF06B6D4)),
          ),
        ),
      ],
    );
  }
}
