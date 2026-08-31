import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;

  const ChallengeCard({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    // 1. Blindagem de Null-Safety para os textos
    final String difficulty =
        challenge['difficulty'] ?? challenge['dificuldade'] ?? "NORMAL";
    final String icon = challenge['icon'] ?? challenge['icone'] ?? "🏆";
    final String theme =
        challenge['theme'] ?? challenge['tema'] ?? "DESAFIO GERAL";
    final String title =
        challenge['title'] ?? challenge['titulo'] ?? "Desafio FitLab";
    final String reward =
        challenge['reward'] ?? challenge['recompensa'] ?? "XP";

    // 2. Conversão segura de números (evita erro se o Java mandar int no lugar de double)
    final double progress =
        (challenge['progress'] ?? challenge['progresso'] ?? 0).toDouble();
    final double total = (challenge['total'] ?? 1)
        .toDouble(); // Evita divisão por zero

    // 3. Lógica da barra (clamp garante que não passe de 1.0)
    final double progressPercent = (progress / total).clamp(0.0, 1.0);

    Color diffColor =
        difficulty.toUpperCase() == "HARD" ||
            difficulty.toUpperCase() == "DIFÍCIL"
        ? Colors.redAccent
        : Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF06B6D4),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: diffColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  difficulty.toUpperCase(),
                  style: TextStyle(
                    color: diffColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: const Color(0xFF06B6D4),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reward,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              Text(
                '${progress.toStringAsFixed(1)} / ${total.toInt()} km',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
