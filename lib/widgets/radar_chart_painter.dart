import 'dart:math';
import 'package:flutter/material.dart';

class RadarChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Color progressColor;

  var color;

  RadarChartPainter({required this.data, required this.color})
    : progressColor = color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 3) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;
    final angleStep = (2 * pi) / data.length;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 1. Desenha a Teia de Fundo
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), gridPaint);
    }

    // Desenha Eixos, Ícones e Labels
    final List<Map<String, String>> eixosInfo = [
      {'label': 'VELOCIDADE', 'icon': '⚡'},
      {'label': 'RESISTÊNCIA', 'icon': '🛡️'},
      {'label': 'CONSISTÊNCIA', 'icon': '🔁'},
      {'label': 'EXPLORAÇÃO', 'icon': '🌍'},
    ];

    for (var i = 0; i < data.length; i++) {
      final angle = angleStep * i - pi / 2;
      final axisEndPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      canvas.drawLine(center, axisEndPoint, gridPaint);
    }

    // Desenha o Polígono
    final progressPath = Path();
    final points = data.values.toList();
    for (var i = 0; i < points.length; i++) {
      final angle = angleStep * i - pi / 2;
      final point = Offset(
        center.dx + radius * points[i] * cos(angle),
        center.dy + radius * points[i] * sin(angle),
      );
      if (i == 0)
        progressPath.moveTo(point.dx, point.dy);
      else
        progressPath.lineTo(point.dx, point.dy);
    }
    progressPath.close();
    canvas.drawPath(
      progressPath,
      Paint()
        ..color = progressColor.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      progressPath,
      Paint()
        ..color = progressColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
