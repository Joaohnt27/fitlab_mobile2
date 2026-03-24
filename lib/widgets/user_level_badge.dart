import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../providers/user_provider.dart';

class UserLevelBadge extends StatelessWidget {
  const UserLevelBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final xp = userProvider.usuarioLogado?.xp ?? 0;

        final nivel = AppData.getNivelAtual(xp);

        // Cálculo do progresso
        double progresso = (xp - nivel['min']) / (nivel['max'] - nivel['min']);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "NÍVEL ${nivel['lv']}",
                    style: const TextStyle(
                      color: Color(0xFF06B6D4),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    "$xp XP",
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                nivel['nome'].toString().toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progresso.isFinite ? progresso.clamp(0.0, 1.0) : 0.0,
                backgroundColor: Colors.white10,
                color: const Color(0xFF06B6D4),
                minHeight: 4,
              ),
            ],
          ),
        );
      },
    );
  }
}
