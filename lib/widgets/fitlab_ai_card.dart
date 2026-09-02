import 'dart:ui';
import 'package:flutter/material.dart';

class FitLabAICard extends StatefulWidget {
  final Function(Map<String, dynamic>) onGenerate;

  const FitLabAICard({super.key, required this.onGenerate});

  @override
  State<FitLabAICard> createState() => _FitLabAICardState();
}

class _FitLabAICardState extends State<FitLabAICard> {
  // Controladores para os campos de texto numéricos e abertos
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _contextoController = TextEditingController();

  // Valores padrão dos seletores
  String _selectedMeta = "Corrida por Hobby";
  String _selectedPrazo = "3 meses (Foco)";
  String _selectedNivel = "Iniciante";

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    _contextoController.dispose();
    super.dispose();
  }

  void _abrirFormularioIA() {
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
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
                      // Usamos StatefulBuilder para atualizar os dropdowns dentro do modal
                      child: StatefulBuilder(
                        builder: (context, setStateModal) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  "BIOMETRIA & METAS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06B6D4),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // --- LINHA 1: PESO E ALTURA ---
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      label: "Peso (kg)",
                                      controller: _pesoController,
                                      icon: Icons.monitor_weight_outlined,
                                      isNumber: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      label: "Altura (cm)",
                                      controller: _alturaController,
                                      icon: Icons.height,
                                      isNumber: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // --- LINHA 2: EXPERIÊNCIA ---
                              _buildDropdown(
                                label: "Nível de Experiência",
                                value: _selectedNivel,
                                options: [
                                  "Iniciante",
                                  "Amador",
                                  "Praticante Assíduo",
                                ],
                                onChanged: (val) =>
                                    setStateModal(() => _selectedNivel = val!),
                              ),
                              const SizedBox(height: 16),

                              // --- LINHA 3: META ---
                              _buildDropdown(
                                label: "Objetivo Principal",
                                value: _selectedMeta,
                                options: [
                                  "Preparar para maratona",
                                  "Corrida por Hobby",
                                  "Performance em Esportes",
                                ],
                                onChanged: (val) =>
                                    setStateModal(() => _selectedMeta = val!),
                              ),
                              const SizedBox(height: 16),

                              // --- LINHA 4: PRAZO ---
                              _buildDropdown(
                                label: "Prazo da Meta",
                                value: _selectedPrazo,
                                options: [
                                  "1 mês (Intensivo)",
                                  "3 meses (Foco)",
                                  "6 meses (Evolução)",
                                ],
                                onChanged: (val) =>
                                    setStateModal(() => _selectedPrazo = val!),
                              ),
                              const SizedBox(height: 16),

                              // --- LINHA 5: CONTEXTO LIVRE ---
                              _buildTextField(
                                label: "Contexto Adicional (Opcional)",
                                hint:
                                    "Ex: Transição da musculação para o cardio...",
                                controller: _contextoController,
                                icon: Icons.notes,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 32),

                              // --- BOTÃO GERAR ---
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Validação básica
                                    if (_pesoController.text.isEmpty ||
                                        _alturaController.text.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Preencha peso e altura para segurança do treino.",
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      return;
                                    }

                                    // Fecha o modal e envia os dados montados
                                    Navigator.pop(context);
                                    widget.onGenerate({
                                      "peso_kg":
                                          double.tryParse(
                                            _pesoController.text,
                                          ) ??
                                          0.0,
                                      "altura_cm":
                                          int.tryParse(
                                            _alturaController.text,
                                          ) ??
                                          0,
                                      "nivel_experiencia": _selectedNivel,
                                      "meta": _selectedMeta,
                                      "prazo": _selectedPrazo,
                                      "contexto_adicional":
                                          _contextoController.text,
                                    });
                                  },
                                  icon: const Icon(Icons.bolt, size: 20),
                                  label: const Text(
                                    "SINTETIZAR TREINO IA",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF06B6D4),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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

  // Widget auxiliar para os campos de texto
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isNumber = false,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: const Color(0xFF06B6D4), size: 18)
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1),
            ),
          ),
        ),
      ],
    );
  }

  // Widget auxiliar para os menus Dropdown
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: const Color(0xFF1A1A1A),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF06B6D4)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: options.map((String opt) {
            return DropdownMenuItem<String>(
              value: opt,
              child: Text(
                opt,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
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
            "Crie um treino biomecanicamente seguro baseado na sua experiência e meta.",
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
              "Operado por Google Gemini",
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
        onPressed: _abrirFormularioIA,
        icon: const Icon(Icons.bolt, size: 18),
        label: const Text(
          "CONFIGURAR TREINO",
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
