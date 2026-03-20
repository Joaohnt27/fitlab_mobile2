import 'package:flutter/material.dart';
import 'radar_chart_painter.dart';

class AnimatedRadarChart extends StatefulWidget {
  final Map<String, double> data;
  final Color color;

  const AnimatedRadarChart({
    super.key,
    required this.data,
    required this.color,
  });

  @override
  State<AnimatedRadarChart> createState() => _AnimatedRadarChartState();
}

class _AnimatedRadarChartState extends State<AnimatedRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedRadarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        Map<String, double> animatedData = widget.data.map((key, value) {
          return MapEntry(key, value * _animation.value);
        });

        return CustomPaint(
          size: const Size(200, 200),
          painter: RadarChartPainter(data: animatedData, color: widget.color),
        );
      },
    );
  }
}
