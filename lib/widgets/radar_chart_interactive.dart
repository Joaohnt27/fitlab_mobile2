import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
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
      width: 300, 
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedRadarChart(data: data, color: color),

          // VELOCIDADE
          Positioned(
            top: 0,
            child: _buildAttributeIcon(
              context,
              'assets/icons/bolt.svg', 
              'VELOCIDADE',
              'Meteora de Pace: Indica sua capacidade explosiva e eficiência cardiovascular.',
            ),
          ),

          // CONSISTÊNCIA
          Positioned(
            bottom: 0,
            child: _buildAttributeIcon(
              context,
              'assets/icons/repeat.svg',
              'CONSISTÊNCIA',
              'Disciplina Absurda: Avalia a frequência semanal e dias seguidos.',
            ),
          ),

          // RESISTÊNCIA
          Positioned(
            right: 0,
            child: _buildAttributeIcon(
              context,
              'assets/icons/shield.svg',
              'RESISTÊNCIA',
              'Vontade de Ferro: Baseado na distância média e tempo contínuo correndo.',
            ),
          ),

          // EXPLORAÇÃO
          Positioned(
            left: 0,
            child: _buildAttributeIcon(
              context,
              'assets/icons/globe.svg',
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
    String svgPath, 
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.2),
              ), 
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              svgPath,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                color,
                BlendMode.srcIn,
              ), 
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
