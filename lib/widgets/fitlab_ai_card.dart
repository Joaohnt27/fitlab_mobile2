import 'dart:ui';
import 'package:flutter/material.dart';

class FitLabAICard extends StatefulWidget {
  final Function(Map<String, dynamic>) onGenerate;

  const FitLabAICard({super.key, required this.onGenerate});

  @override
  State<FitLabAICard> createState() => _FitLabAICardState();
}

class _FitLabAICardState extends State<FitLabAICard> {
  Map<String, dynamic> aiRequestData = {"goal": "", "timeframe": ""};

  void _iniciarFluxoIA() {
    _showSelectionDialog(
      title: "QUAL SUA META?",
      options: [
        {"label": "Preparar para Maratona", "value": "marathon", "icon": "🏁"},
        {"label": "Corrida por Hobby", "value": "hobby", "icon": "🌳"},
        {
          "label": "Performance em Esportes",
          "value": "performance",
          "icon": "⚡",
        },
      ],
      onSelected: (val) {
        aiRequestData["goal"] = val;
        Navigator.pop(context);
        _passo2IA();
      },
    );
  }

  void _passo2IA() {
    _showSelectionDialog(
      title: "PRAZO DO OBJETIVO",
      options: [
        {"label": "1 Mês (Intensivo)", "value": "1_month", "icon": "📅"},
        {"label": "3 Meses (Foco)", "value": "3_months", "icon": "🎯"},
        {"label": "6 Meses (Evolução)", "value": "6_months", "icon": "📈"},
      ],
      onSelected: (val) {
        aiRequestData["timeframe"] = val;
        Navigator.pop(context);
        widget.onGenerate(aiRequestData);
      },
    );
  }

  void _showSelectionDialog({
    required String title,
    required List<Map<String, String>> options,
    required Function(String) onSelected,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(2), // Borda gradiente
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF06B6D4),
                      Colors.transparent,
                      Color(0xFF1D4ED8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF06B6D4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...options.map(
                          (opt) => _buildOptionItem(opt, onSelected),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(
    Map<String, String> opt,
    Function(String) onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => onSelected(opt["value"]!),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Text(opt["icon"]!, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  opt["label"]!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF06B6D4),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [const Color(0xFF06B6D4).withOpacity(0.15), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          const Text(
            "Crie um treino personalizado baseado no seu cansaço e objetivo.",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 20),
          _buildButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF06B6D4).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.psychology,
            color: Color(0xFF06B6D4),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "GERADOR DE TREINOS",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              "Powered by FitLab AI",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _iniciarFluxoIA,
        icon: const Icon(Icons.bolt, size: 18),
        label: const Text(
          "GERAR TREINO AGORA",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF06B6D4),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
