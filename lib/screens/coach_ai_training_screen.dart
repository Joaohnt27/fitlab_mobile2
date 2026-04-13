import 'package:flutter/material.dart';
import 'dart:ui';

class CoachAITrainingScreen extends StatefulWidget {
  const CoachAITrainingScreen({super.key});

  @override
  State<CoachAITrainingScreen> createState() => _CoachAITrainingScreenState();
}

class _CoachAITrainingScreenState extends State<CoachAITrainingScreen> {
  bool _isProcessing = false;
  String _selectedScope = "Turma Elite Sprint";
  String _selectedGoal = "Aumento de VO2 Max";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "IA - CO-PILOTO ELITE",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAIPromptHeader(),
                const SizedBox(height: 32),
                _buildSectionLabel("FONTE DE DADOS"),
                const SizedBox(height: 12),
                _buildTargetSelector(),
                const SizedBox(height: 24),
                _buildSectionLabel("OBJETIVO DO ALGORITMO"),
                const SizedBox(height: 12),
                _buildGoalSelector(),
                const SizedBox(height: 32),
                _buildSectionLabel("CONFIGURAÇÕES ADICIONAIS"),
                const SizedBox(height: 12),
                _buildExtraToggle("Considerar fadiga acumulada (RPE)"),
                _buildExtraToggle("Ajustar volume por clima local"),
                const SizedBox(height: 40),
                _buildGenerateButton(),
              ],
            ),
          ),
          if (_isProcessing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAIPromptHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF06B6D4).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.psychology_rounded, color: Color(0xFF06B6D4), size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SINTETIZADOR ELITE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "A IA analisará o desempenho recente dos atletas para sugerir a carga ideal.",
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF06B6D4),
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildTargetSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedScope,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A1A),
          items:
              ["Turma Elite Sprint", "Maratonistas Z2", "Atleta Arthur Vital"]
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (v) => setState(() => _selectedScope = v!),
        ),
      ),
    );
  }

  Widget _buildGoalSelector() {
    final goals = [
      "Aumento de VO2 Max",
      "Recuperação Ativa",
      "Poliimento p/ Prova",
      "Base de Volume",
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: goals.map((goal) {
        bool isSelected = _selectedGoal == goal;
        return GestureDetector(
          onTap: () => setState(() => _selectedGoal = goal),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF06B6D4)
                  : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              goal,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExtraToggle(String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
      trailing: Switch(
        value: true,
        onChanged: (v) {},
        activeColor: const Color(0xFF06B6D4),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          setState(() => _isProcessing = true);
          Future.delayed(const Duration(seconds: 3), () {
            setState(() => _isProcessing = false);
            _showResultModal();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text(
          "SINTETIZAR FÓRMULA",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black54,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF06B6D4)),
              SizedBox(height: 24),
              Text(
                "PROCESSANDO BIOMETRIAS...",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PROPOSTA DA IA",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Baseado nos últimos 14 dias da Turma Elite Sprint, a sugestão é:",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "Treino: 8x 400m em ritmo Z5\nIntervalo: 90s trote passivo\nJustificativa: Compensar a queda de volume na última quarta-feira.",
                style: TextStyle(
                  color: Color(0xFF06B6D4),
                  fontFamily: 'Courier',
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("DESCARTAR"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                    ),
                    child: const Text(
                      "APROVAR E DISPARAR",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
