import 'package:flutter/material.dart';
import '../screens/challenge_details_screen.dart';

class TrendingChallengeCard extends StatelessWidget {
  final Map<String, dynamic> desafio;

  const TrendingChallengeCard({super.key, required this.desafio});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'bolt':
        return Icons.bolt;
      case 'nightlight_round':
        return Icons.nightlight_round;
      case 'map':
        return Icons.map;
      default:
        return Icons.flag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = desafio['titulo'] ?? 'Desafio';
    final xp = desafio['recompensaXp']?.toString() ?? '0';
    final iconStr = desafio['imagem'] ?? 'flag';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeDetailsScreen(desafio: desafio),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(iconStr),
                color: const Color(0xFF06B6D4),
                size: 20,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Desafio Global",
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 4),
                Text(
                  "$xp XP",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
