import 'package:flutter/material.dart';
import 'animated_radar_chart.dart';

class RadarChartInteractive extends StatelessWidget {
  final Map<String, double> data;
  final Color color;

  const RadarChartInteractive({
    super.key,
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280, 
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // gráfico no fundo
          AnimatedRadarChart(data: data, color: color),

          // Ícones posicionados nas extremidades
          // TOPO - VELOCIDADE
          Positioned(
            top: 0,
            child: _buildAttributeIcon(
              context,
              '⚡',
              'VELOCIDADE',
              'Meteora de Pace: Indica sua capacidade explosiva e eficiência cardiovascular.',
            ),
          ),

          // BAIXO - CONSISTÊNCIA
          Positioned(
            bottom: 0,
            child: _buildAttributeIcon(
              context,
              '🔁',
              'CONSISTÊNCIA',
              'Disciplina Absurda: Avalia a frequência semanal e dias seguidos.',
            ),
          ),

          // DIREITA - RESISTÊNCIA
          Positioned(
            right: 0,
            child: _buildAttributeIcon(
              context,
              '🛡️',
              'RESISTÊNCIA',
              'Vontade de Ferro: Baseado na distância média e tempo contínuo correndo.',
            ),
          ),

          // ESQUERDA - EXPLORAÇÃO
          Positioned(
            left: 0,
            child: _buildAttributeIcon(
              context,
              '🌍',
              'EXPLORAÇÃO',
              'Cartógrafo das Ruas: Mede a variedade de rotas e novos locais.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeIcon(
    BuildContext context,
    String icon,
    String title,
    String desc,
  ) {
    return Tooltip(
      message: "$title\n$desc",
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      showDuration: const Duration(seconds: 3),
      triggerMode: TooltipTriggerMode.tap, 
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
