import 'package:flutter/material.dart';

class LabGoalsCard extends StatefulWidget {
  // Alterado para receber os dados capturados
  final Function(String volume, String frequencia) onIniciar;

  const LabGoalsCard({super.key, required this.onIniciar});

  @override
  State<LabGoalsCard> createState() => _LabGoalsCardState();
}

class _LabGoalsCardState extends State<LabGoalsCard> {
  int _buttonState = 0;

  // Controllers para capturar o que o usuário digita
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _frequenciaController = TextEditingController();

  @override
  void dispose() {
    _volumeController.dispose();
    _frequenciaController.dispose();
    super.dispose();
  }

  void _handlePress() async {
    if (_buttonState != 0) return;

    // Captura os valores atuais dos campos
    String volume = _volumeController.text;
    String freq = _frequenciaController.text;

    // Validação simples para não iniciar vazio
    if (volume.isEmpty || freq.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os campos do experimento!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _buttonState = 1);

    // Simula o tempo de "mistura" (2 segundos)
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _buttonState = 2);

    // Envia os dados para a WorkoutsScreen
    widget.onIniciar(volume, freq);

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
                "Defina a fórmula da sua evolução!",
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
          // Passando o controller para o input
          _buildGoalInput(
            "Meta de Volume (KM)",
            "Ex: 40km",
            Icons.straighten,
            _volumeController,
          ),
          const SizedBox(height: 16),
          _buildGoalInput(
            "Frequência Semanal (dias)",
            "Ex: 4 dias",
            Icons.calendar_today,
            _frequenciaController,
          ),
          const SizedBox(height: 24),

          // BOTÃO ANIMADO 
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
        "INICIAR EXPERIMENTO",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      );
    }
  }

  Widget _buildGoalInput(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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
