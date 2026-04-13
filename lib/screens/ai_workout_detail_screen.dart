import 'package:flutter/material.dart';

class AIWorkoutDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const AIWorkoutDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "RELATÓRIO DE SÍNTESE",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),

            // GRID DE MÉTRICAS RÁPIDAS
            Row(
              children: [
                _buildMetricBox("DISTÂNCIA", "5.2 km", Icons.straighten),
                const SizedBox(width: 12),
                _buildMetricBox("JANELA", "35-45 min", Icons.timer),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              "PROTOCOLO DE AQUECIMENTO",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            _buildWarmupList(),

            const SizedBox(height: 32),
            const Text(
              "EXECUÇÃO PRINCIPAL",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            _buildMainInstruction(),

            const SizedBox(height: 40),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data['goal']?.toString().toUpperCase() ?? "PERFORMANCE",
          style: const TextStyle(
            color: Color(0xFF06B6D4),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Protocolo de treinamento",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "Baseado na sua biometria e histórico de 30 dias.",
          style: TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildMetricBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF06B6D4), size: 18),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarmupList() {
    final warmups = [
      "Mobilidade de Tornozelo (2x15)",
      "Elevação de Joelhos (30s)",
      "Caminhada Ativa (5 min em Pace 8:00)",
    ];
    return Column(
      children: warmups
          .map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.science, color: Color(0xFF06B6D4), size: 14),
                  const SizedBox(width: 12),
                  Text(
                    w,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMainInstruction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF06B6D4).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.2)),
      ),
      child: const Text(
        "Corra os primeiros 2km em ritmo de Z2 (confortável). Aumente para Z4 nos 2km seguintes e finalize com 1.2km de desaquecimento.",
        style: TextStyle(color: Colors.white, height: 1.5, fontSize: 14),
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          // IMPLEMENTAR: IR PARA A TELA DE INICIAR O TREINO
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text(
          "INICIAR TREINO",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
