import 'dart:async';
import 'package:fitlab_mobile2/screens/ai_workout_detail_screen.dart';
import 'package:flutter/material.dart';

class AITrainingResultCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onStart;

  const AITrainingResultCard({
    super.key,
    required this.data,
    required this.onStart,
  });

  @override
  State<AITrainingResultCard> createState() => _AITrainingResultCardState();
}

class _AITrainingResultCardState extends State<AITrainingResultCard> {
  late Timer _timer;
  late Duration _timeLeft;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _timeLeft = const Duration(hours: 0, minutes: 1, seconds: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        setState(() {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
        });
      } else {
        setState(() {
          _isExpired = true;
          _timer.cancel();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final String tituloIA = widget.data['titulo'] ?? 'Fórmula Sintetizada';
    final Map<String, dynamic>? inputs = widget.data['inputs_usuario'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _isExpired
              ? Colors.white10
              : const Color(0xFF06B6D4).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "FÓRMULA SINTETIZADA",
                style: TextStyle(
                  color: const Color(0xFF06B6D4).withOpacity(0.8),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
              _buildExpiryBadge(),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _isExpired ? "SESSÃO EXPIRADA" : tituloIA,
            style: TextStyle(
              color: _isExpired ? Colors.white24 : Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          // 👇 NOVO: Resumo do Pedido do Usuário (Renderizado apenas se não estiver expirado)
          if (inputs != null && !_isExpired) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInputBadge(Icons.bolt, inputs['nivel'] ?? ''),
                _buildInputBadge(
                  Icons.monitor_weight_outlined,
                  "${inputs['peso']}kg | ${inputs['altura']}cm",
                ),
                _buildInputBadge(Icons.flag, inputs['meta'] ?? ''),
              ],
            ),
          ],

          const SizedBox(height: 24),
          if (_isExpired) _buildExpiredView() else _buildActiveView(),
        ],
      ),
    );
  }

  // 👇 NOVO: Widget que desenha as tags bonitinhas
  Widget _buildInputBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
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
        color: _isExpired ? Colors.black : Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _isExpired
              ? Colors.white10
              : Colors.redAccent.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history_toggle_off,
            color: _isExpired ? Colors.white24 : Colors.redAccent,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(_timeLeft),
            style: TextStyle(
              color: _isExpired ? Colors.white24 : Colors.redAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveView() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AIWorkoutDetailScreen(data: widget.data),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF06B6D4),
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text(
        "ACESSAR TREINO",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExpiredView() {
    return Column(
      children: [
        const Text(
          "Esta fórmula química perdeu a estabilidade após 24h.",
          style: TextStyle(color: Colors.white38, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onStart,
          child: const Text(
            "SINTETIZAR NOVA FÓRMULA",
            style: TextStyle(color: Color(0xFF06B6D4)),
          ),
        ),
      ],
    );
  }
}
