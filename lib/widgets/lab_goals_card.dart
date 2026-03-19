import 'package:flutter/material.dart';

class LabGoalsCard extends StatefulWidget {
  final VoidCallback onIniciar;

  const LabGoalsCard({super.key, required this.onIniciar});

  @override
  State<LabGoalsCard> createState() => _LabGoalsCardState();
}

class _LabGoalsCardState extends State<LabGoalsCard> {
  // Estados do botão: 0 = idle, 1 = loading, 2 = success
  int _buttonState = 0;

  void _handlePress() async {
    if (_buttonState != 0) return;

    setState(() => _buttonState = 1);

    // Simula o tempo de "mistura" do laboratório (2 segundos)
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _buttonState = 2);

    // Chama a função que você definiu na WorkoutsScreen (o SnackBar)
    widget.onIniciar();

    // Volta ao estado original após 3 segundos
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _buttonState = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science, color: Color(0xFF06B6D4), size: 20),
              const SizedBox(width: 8),
              Text(
                "CONFIGURAR EXPERIMENTO",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildGoalInput("Meta de Volume", "Ex: 40km", Icons.straighten),
          const SizedBox(height: 16),
          _buildGoalInput(
            "Frequência Semanal",
            "Ex: 4 dias",
            Icons.calendar_today,
          ),
          const SizedBox(height: 24),

          // --- BOTÃO ANIMADO ---
          SizedBox(
            width: double.infinity,
            height: 50,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton(
                onPressed: _handlePress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonState == 2
                      ? Colors.green
                      : const Color(0xFF06B6D4),
                  foregroundColor: _buttonState == 2
                      ? Colors.white
                      : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      _buttonState == 1 ? 25 : 12,
                    ),
                  ),
                  elevation: _buttonState == 1 ? 0 : 4,
                ),
                child: _buildButtonContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonContent() {
    if (_buttonState == 1) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
      );
    } else if (_buttonState == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check, size: 20),
          SizedBox(width: 8),
          Text(
            "FÓRMULA PRONTA!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      );
    } else {
      return const Text(
        "INICIAR MISTURA",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      );
    }
  }

  Widget _buildGoalInput(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white10),
            prefixIcon: Icon(icon, color: Colors.white24, size: 18),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
