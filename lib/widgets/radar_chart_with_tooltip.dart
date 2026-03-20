import 'package:flutter/material.dart';
import '../models/radar_axis_model.dart';
import 'animated_radar_chart.dart';

class RadarChartWithTooltip extends StatefulWidget {
  final Map<String, double> data;
  final Color color;

  const RadarChartWithTooltip({
    super.key,
    required this.data,
    required this.color,
  });

  @override
  State<RadarChartWithTooltip> createState() => _RadarChartWithTooltipState();
}

class _RadarChartWithTooltipState extends State<RadarChartWithTooltip> {
  RadarAxis? _eixoTocado;
  OverlayEntry? _tooltipEntry;

  void _showScientificTooltip(BuildContext context, RadarAxis axis) {
    _hideTooltip();

    setState(() => _eixoTocado = axis);

    _tooltipEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _hideTooltip,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 24,
            right: 24,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF06B6D4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(axis.icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Text(
                          "ANÁLISE DE ${axis.label}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.white10),
                    ),
                    Text(
                      axis.descricaoCientifica,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Toque em qualquer lugar para fechar",
                      style: TextStyle(color: Colors.white10, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_tooltipEntry!);
  }

  void _hideTooltip() {
    if (_tooltipEntry != null) {
      _tooltipEntry!.remove();
      _tooltipEntry = null;
      if (mounted) setState(() => _eixoTocado = null);
    }
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        final Size size = context.size!;
        final Offset localPosition = details.localPosition;
        final Offset center = Offset(size.width / 2, size.height / 2);

        // Define a "zona de toque" ao redor dos emojis nas pontas
        double margem = 40.0;
        double radiusForTouch = (size.width / 2) + 15; // Onde os emojis estão

        // Topo (Velocidade)
        if (localPosition.dx > center.dx - margem &&
            localPosition.dx < center.dx + margem &&
            localPosition.dy < center.dy - radiusForTouch + margem) {
          _showScientificTooltip(context, eixosDoFitLab[0]); // VELOCIDADE
        }
        // Direita (Resistência)
        else if (localPosition.dx > center.dx + radiusForTouch - margem &&
            localPosition.dy > center.dy - margem &&
            localPosition.dy < center.dy + margem) {
          _showScientificTooltip(context, eixosDoFitLab[1]); // RESISTÊNCIA
        }
        // Base (Consistência)
        else if (localPosition.dx > center.dx - margem &&
            localPosition.dx < center.dx + margem &&
            localPosition.dy > center.dy + radiusForTouch - margem) {
          _showScientificTooltip(context, eixosDoFitLab[2]); // CONSISTÊNCIA
        }
        // Esquerda (Exploração)
        else if (localPosition.dx < center.dx - radiusForTouch + margem &&
            localPosition.dy > center.dy - margem &&
            localPosition.dy < center.dy + margem) {
          _showScientificTooltip(context, eixosDoFitLab[3]); // EXPLORAÇÃO
        }
      },
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          color: Colors.transparent,
          child: AnimatedRadarChart(data: widget.data, color: widget.color),
        ),
      ),
    );
  }
}
