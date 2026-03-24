import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import 'badge_detail_dialog.dart'; 

class BadgeItem extends StatelessWidget {
  final BadgeModel badge;
  final BuildContext context; 

  const BadgeItem({super.key, required this.badge, required this.context});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Ao clicar, abre o diálogo de detalhes (indiferente se está trancado ou não)
        showDialog(
          context: context,
          builder: (context) => BadgeDetailDialog(badge: badge),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // Gradiente só aparece se desbloqueado
              gradient: badge.isUnlocked
                  ? LinearGradient(
                      colors: badge.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              // Fundo cinza escuro se trancado
              color: badge.isUnlocked ? null : Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  // Opacidade baixa se trancado
                  opacity: badge.isUnlocked ? 1.0 : 0.2,
                  child: Text(badge.icon, style: const TextStyle(fontSize: 30)),
                ),
                // Ícone de cadeado 
                if (!badge.isUnlocked)
                  const Icon(
                    Icons.lock_outline,
                    color: Colors.white24,
                    size: 20,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.name, 
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              // Cor apagada se trancado
              color: badge.isUnlocked ? Colors.white70 : Colors.white24,
              fontSize: 9,
              height: 1.1,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis, // Bota "..." se estourar
          ),
        ],
      ),
    );
  }
}
