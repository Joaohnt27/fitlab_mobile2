import 'package:flutter/material.dart';

class AIWorkoutDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const AIWorkoutDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // 1. Extração dos dados principais do plano
    final Map<String, dynamic>? inputsUsuario = data['inputs_usuario'];
    final String meta =
        inputsUsuario?['meta']?.toString().toUpperCase() ?? "PERFORMANCE";
    final String tituloIA = data['titulo'] ?? "Protocolo de Treinamento";
    final String focoIA =
        data['foco'] ?? "Baseado na sua biometria e histórico de 30 dias.";

    // 2. Extração das listas dinâmicas geradas pela IA
    final List<dynamic> dias = data['dias'] ?? [];
    final List<dynamic> aquecimento =
        data['aquecimento'] ?? ["Mobilidade básica (5 min)"];

    // 3. Cálculo de Volume Total e Média de Tempo
    double distanciaTotal = 0;
    for (var dia in dias) {
      distanciaTotal +=
          double.tryParse(dia['distancia_km']?.toString() ?? "0") ?? 0;
    }
    final String janelaMedia =
        "${(distanciaTotal * 5).round()}-${(distanciaTotal * 7).round()} min/dia";

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
            _buildHeader(meta, tituloIA, focoIA),
            const SizedBox(height: 32),

            Row(
              children: [
                _buildMetricBox(
                  "VOL. TOTAL",
                  "${distanciaTotal.toStringAsFixed(1)} km",
                  Icons.straighten,
                ),
                const SizedBox(width: 12),
                _buildMetricBox("MÉDIA DIÁRIA", janelaMedia, Icons.timer),
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

            // 👇 Renderiza os aquecimentos dinâmicos
            Column(
              children: aquecimento
                  .map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.science,
                            color: Color(0xFF06B6D4),
                            size: 14,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              w.toString(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 32),
            const Text(
              "CRONOGRAMA DE EXECUÇÃO",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),

            // 👇 Renderiza TODOS os dias que a IA gerou
            Column(
              children: dias
                  .map(
                    (dia) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF06B6D4).withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dia['dia'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "${dia['distancia_km']} km",
                                style: const TextStyle(
                                  color: Color(0xFF06B6D4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            dia['descricao'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.5,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 40),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String meta, String titulo, String foco) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meta,
          style: const TextStyle(
            color: Color(0xFF06B6D4),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          foco,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.4,
          ),
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
