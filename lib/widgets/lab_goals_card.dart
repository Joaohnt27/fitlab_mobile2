import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class LabGoalsCard extends StatefulWidget {
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

    String volume = _volumeController.text;
    String freq = _frequenciaController.text;

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

    // Simula o tempo de "mistura" química (2 segundos)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    //Salva os dados no Provider
    Provider.of<UserProvider>(
      context,
      listen: false,
    ).salvarExperimentoUsuario(context, volume, freq);

    // Muda para o estado de Sucesso
    setState(() => _buttonState = 2);

    // Exibe o Card de confirmação "Fórmula Pronta"
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.science, color: Color(0xFF06B6D4), size: 60),
                const SizedBox(height: 24),
                const Text(
                  "FÓRMULA PRONTA!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Seu experimento de $volume km em $freq dias foi configurado com sucesso e já está rodando no seu Feed.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "VAMOS NESSA!",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

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
