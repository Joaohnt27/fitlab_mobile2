import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../providers/user_provider.dart';

class FeedLevelRadial extends StatelessWidget {
  const FeedLevelRadial({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final xp = userProvider.usuarioLogado?.xp ?? 0;

        final nivel = AppData.getNivelAtual(xp);

        double progressoPercentual =
            (xp - nivel['min']) / (nivel['max'] - nivel['min']);

        return Tooltip(
          message: "${nivel['nome']}\nPróximo nível em ${nivel['max'] - xp} XP",
          triggerMode: TooltipTriggerMode.longPress,
          textStyle: const TextStyle(color: Colors.black, fontSize: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                // PARTE RADIAL
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(50, 50),
                        painter: RadialProgressPainter(
                          progress: progressoPercentual.isFinite
                              ? progressoPercentual.clamp(0.0, 1.0)
                              : 0.0,
                          color: const Color(0xFF06B6D4),
                        ),
                      ),
                      Text(nivel['icon'], style: const TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // TEXTOS DO CARD
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "NÍVEL ${nivel['lv']}",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        nivel['nome'].toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "$xp XP",
                  style: const TextStyle(color: Colors.white12, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Classe que desenha o arco
class RadialProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  RadialProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    Paint progressPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = (size.width / 2);

    // Desenha o círculo de fundo
    canvas.drawCircle(center, radius, backgroundPaint);

    // Desenha o arco de progresso
    double angle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
