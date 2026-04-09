import 'package:flutter/material.dart';
import 'dart:ui';

class CountdownOverlay extends StatelessWidget {
  final int value;

  const CountdownOverlay({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.7)),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              key: ValueKey(value),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutBack,
              builder: (context, animValue, child) {
                final safeOpacity = animValue.clamp(0.0, 1.0);

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo Neon
                    Transform.scale(
                      scale: 1.0 + (animValue * 0.2),
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFF06B6D4,
                            ).withOpacity(1.0 - safeOpacity),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF06B6D4,
                              ).withOpacity(0.3 * (1.0 - safeOpacity)),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Círculo Preto Central
                    Container(
                      width: 180,
                      height: 180,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),

                    // Texto Animado
                    Transform.scale(
                      scale: 0.5 + (animValue * 1.0),
                      child: Opacity(
                        opacity: safeOpacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getFormattedValue(),
                              style: TextStyle(
                                color: value == 1
                                    ? const Color(0xFF2DE372)
                                    : Colors.white,
                                fontSize: value == 1 ? 60 : 90,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedValue() {
    switch (value) {
      case 6:
        return "5";
      case 5:
        return "4";
      case 4:
        return "3";
      case 3:
        return "2";
      case 2:
        return "1";
      case 1:
        return "VAI!";
      default:
        return "";
    }
  }
}
