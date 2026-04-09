import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SummarySheet extends StatefulWidget {
  final List<LatLng> route;
  final double distance;
  final int duration;
  final int xp;
  final String pace;
  final VoidCallback onClose;

  const SummarySheet({
    super.key,
    required this.route,
    required this.distance,
    required this.duration,
    required this.xp,
    required this.pace,
    required this.onClose,
  });

  @override
  State<SummarySheet> createState() => _SummarySheetState();
}

class _SummarySheetState extends State<SummarySheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _medalController;
  late Animation<double> _medalAnimation;

  @override
  void initState() {
    super.initState();
    _medalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _medalAnimation = CurvedAnimation(
      parent: _medalController,
      curve: Curves.elasticOut,
    );
    _medalController.forward();
  }

  @override
  void dispose() {
    _medalController.dispose();
    super.dispose();
  }

  // Lógica para abrir o menu de compartilhamento
  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "COMPARTILHAR RESULTADO",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.dynamic_feed_rounded,
                  color: Color(0xFF06B6D4),
                ),
                title: const Text(
                  "Postar no Feed FitLab",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Aqui futuramente você chamará o Provider de Posts
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Publicado com sucesso no seu Feed!"),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.message, color: const Color(0xFF25D366)),
                title: const Text(
                  "Enviar via WhatsApp",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFFE4405F),
                ),
                title: const Text(
                  "Stories do Instagram",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng mapCenter = widget.route.isNotEmpty
        ? widget.route[widget.route.length ~/ 2]
        : const LatLng(-21.1767, -47.8208);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // 1. Mapa de Fundo
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                  ),
                ],
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Spacer(),
              ScaleTransition(
                scale: _medalAnimation,
                child: const Text("🥇", style: TextStyle(fontSize: 80)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  "EXPERIMENTO CONCLUÍDO",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                "Sua biometria evoluiu no Lab.",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),

              const Spacer(),

              // 2. Mini mapa centralizado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                    color: Colors.black26,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: mapCenter,
                        initialZoom: 14,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                        ),
                        if (widget.route.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: widget.route,
                                color: const Color(0xFF06B6D4),
                                strokeWidth: 5,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 3. Grid de Estatísticas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat(
                      "DISTÂNCIA",
                      "${widget.distance.toStringAsFixed(2)} km",
                    ),
                    _buildStat("GANHOS", "+${widget.xp} XP", isXP: true),
                    _buildStat("RITMO", widget.pace),
                  ],
                ),
              ),

              const Spacer(),

              // Botões Finais
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _showShareOptions(context), // ACIONA O MENU
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 55),
                        ),
                        child: const Text("COMPARTILHAR"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06B6D4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 55),
                        ),
                        child: const Text(
                          "FECHAR",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String val, {bool isXP = false}) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            color: isXP ? const Color(0xFF06B6D4) : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
