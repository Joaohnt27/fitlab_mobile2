import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import necessário
import '../models/app_data.dart';
import '../providers/user_provider.dart'; // Import necessário
import '../screens/levels_detail_screen.dart';

class ProfileLevelCard extends StatelessWidget {
  const ProfileLevelCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Trocamos o ValueListenableBuilder pelo Consumer
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Pegamos o XP real do usuário logado
        final xp = userProvider.usuarioLogado?.xp ?? 0;

        // Usamos a lógica do AppData para calcular o nível com base nesse XP
        final nivel = AppData.getNivelByXP(xp);

        // Cálculo do progresso da barra
        double progresso = (xp - nivel['min']) / (nivel['max'] - nivel['min']);

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
                    "$xp XP", // Agora esse valor é dinâmico!
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    nivel['nome'].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(nivel['icon'], style: const TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progresso.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  color: const Color(0xFF06B6D4),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LevelsDetailScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color(0xFF06B6D4).withOpacity(0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "VER TODOS OS NÍVEIS E XP",
                    style: TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
