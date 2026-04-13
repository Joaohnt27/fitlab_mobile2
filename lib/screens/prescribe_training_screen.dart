import 'package:fitlab_mobile2/screens/prescription_history_screen.dart';
import 'package:flutter/material.dart';

class PrescribeTrainingScreen extends StatefulWidget {
  const PrescribeTrainingScreen({super.key});

  @override
  State<PrescribeTrainingScreen> createState() =>
      _PrescribeTrainingScreenState();
}

class _PrescribeTrainingScreenState extends State<PrescribeTrainingScreen> {
  int _targetType = 0; // 0 para Individual, 1 para Turma
  String? _selectedTarget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "SÍNTESE DE TREINO",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.history_rounded,
              color: Color(0xFF06B6D4),
              size: 26,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrescriptionHistoryScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("CANAL DE DISPARO"),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 32),

            _buildLabel("RECEPTOR DO EXPERIMENTO"),
            const SizedBox(height: 12),
            _buildTargetDropdown(),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Divider(color: Colors.white10, thickness: 1),
            ),

            _buildLabel("PARÂMETROS TÉCNICOS"),
            const SizedBox(height: 20),
            _buildInputField(
              "Identificação do Treino",
              "Ex: Sprint de Explosão",
              Icons.bolt_rounded,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              "Volume da Carga",
              "Ex: 12km ou 45 min",
              Icons.timer_outlined,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              "Protocolo de Execução",
              "Descreva a intensidade, pace e intervalos...",
              Icons.subject_rounded,
              maxLines: 5,
            ),

            const SizedBox(height: 48),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
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

  Widget _buildTypeSelector() {
    return Row(
      children: [
        _selectorCard(0, "ATLETA", Icons.person_rounded),
        const SizedBox(width: 12),
        _selectorCard(1, "TURMA", Icons.groups_rounded),
      ],
    );
  }

  Widget _selectorCard(int index, String label, IconData icon) {
    bool isSelected = _targetType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _targetType = index;
          _selectedTarget = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF06B6D4).withOpacity(0.1)
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF06B6D4)
                  : Colors.white.withOpacity(0.05),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF06B6D4) : Colors.white24,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetDropdown() {
    List<String> items = _targetType == 0
        ? ["Arthur Fontana", "João Henrique", "Maria Cobaia", "Lucas Rocha"]
        : [
            "Elite Sprint",
            "Maratonistas Z2",
            "Iniciantes Lab",
            "Triathlon Team",
          ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTarget,
          hint: Text(
            _targetType == 0 ? "Escolher Aluno..." : "Escolher Turma...",
            style: const TextStyle(color: Colors.white24, fontSize: 14),
          ),
          dropdownColor: const Color(0xFF1A1A1A),
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF06B6D4)),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedTarget = newValue),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextField(
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF06B6D4).withOpacity(0.5),
              size: 20,
            ),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white10, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            contentPadding: const EdgeInsets.all(20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFF06B6D4),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          _showSuccessFeedback();
          Future.delayed(
            const Duration(seconds: 2),
            () => Navigator.pop(context),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          "DISPARAR PROTOCOLO",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  void _showSuccessFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF06B6D4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.black),
            SizedBox(width: 12),
            Text(
              "Treino enviado ao laboratório do atleta!",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
