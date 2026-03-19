import 'package:flutter/material.dart';

class PaceCalculatorCard extends StatelessWidget {
  final TextEditingController distController;
  final TextEditingController tempoController;
  final String resultado;
  final VoidCallback onCalcular;

  const PaceCalculatorCard({
    super.key,
    required this.distController,
    required this.tempoController,
    required this.resultado,
    required this.onCalcular,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInput("DISTÂNCIA (KM)", distController)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput("TEMPO (MIN)", tempoController)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "RITMO ALVO",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    resultado,
                    style: const TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    "min/km",
                    style: TextStyle(color: Color(0xFF06B6D4), fontSize: 12),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onCalcular,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "CALCULAR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF06B6D4),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF06B6D4)),
            ),
          ),
        ),
      ],
    );
  }
}
