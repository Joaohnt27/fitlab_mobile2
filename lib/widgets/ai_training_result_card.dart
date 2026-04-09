import 'package:flutter/material.dart';

class AITrainingResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onStart;

  const AITrainingResultCard({
    super.key,
    required this.data,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF06B6D4).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do Card: Status e Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF06B6D4),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "FÓRMULA SINTETIZADA",
                    style: TextStyle(
                      color: const Color(0xFF06B6D4).withOpacity(0.8),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              _buildExpiryBadge(),
            ],
          ),
          const SizedBox(height: 20),

          // Título dinâmico baseado na meta escolhida
          Text(
            _generateTitle(data['goal']),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Plano otimizado para ${data['timeframe'] == '1_month' ? 'curto prazo' : 'evolução constante'}.",
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),

          const SizedBox(height: 24),

          // Grid de Detalhes Técnicos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(Icons.timer_outlined, "45 min", "Duração"),
              _buildMetric(Icons.bolt, "Alta", "Intensidade"),
              _buildMetric(Icons.trending_up, "5.2 km", "Meta Vol."),
            ],
          ),

          const SizedBox(height: 28),

          // Botão de Ação Principal
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF06B6D4).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "INICIAR EXPERIMENTO",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.history_toggle_off, color: Colors.redAccent, size: 12),
          SizedBox(width: 4),
          Text(
            "23:59h",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF06B6D4), size: 14),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white24,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _generateTitle(String? goal) {
    switch (goal) {
      case 'marathon':
        return "Resistência de Elite";
      case 'performance':
        return "Explosão Metabólica";
      case 'hobby':
        return "Manutenção Vital";
      default:
        return "Protocolo Alpha";
    }
  }
}
