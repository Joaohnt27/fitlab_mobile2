import 'package:fitlab_mobile2/screens/challenge_history_screen.dart';
import 'package:flutter/material.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  int _targetType = 1; // Default para Turma (mais comum em desafios)
  String? _selectedTarget;
  String _selectedMetric = "Quilometragem Total";
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "SÍNTESE DE DESAFIO",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Color(0xFF06B6D4)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChallengeHistoryScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel("CANAL DE DISPARO"),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 20),
            _buildTargetDropdown(),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Divider(color: Colors.white10),
            ),

            _buildSectionLabel("IDENTIFICAÇÃO DO EXPERIMENTO"),
            const SizedBox(height: 20),
            _buildInputField(
              "Título do Desafio",
              "Ex: Sprint de Outono",
              Icons.emoji_events_outlined,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              "Objetivo Científico",
              "Ex: Testar resistência em subida...",
              Icons.biotech_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 32),
            _buildSectionLabel("METODOLOGIA E PRAZO"),
            const SizedBox(height: 20),
            _buildMetricSelector(),
            const SizedBox(height: 20),
            _buildDatePicker(context),

            const SizedBox(height: 32),
            _buildSectionLabel("RECOMPENSA"),
            const SizedBox(height: 16),
            _buildRewardCard(),

            const SizedBox(height: 48),
            _buildLaunchButton(),
            const SizedBox(height: 40),
          ],
        ),
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

  Widget _buildTypeSelector() {
    return Row(
      children: [
        _selectorCard(0, "INDIVIDUAL", Icons.person_rounded),
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF06B6D4).withOpacity(0.1)
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF06B6D4)
                  : Colors.white.withOpacity(0.05),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF06B6D4) : Colors.white24,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
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
        ? ["Arthur Fontana", "João Henrique", "Maria Cobaia", "Todos os Alunos"]
        : [
            "Elite Sprint",
            "Maratonistas Z2",
            "Iniciantes Lab",
            "Todas as Turmas",
          ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTarget,
          hint: Text(
            _targetType == 0 ? "Escolher Atleta..." : "Escolher Turma...",
            style: const TextStyle(color: Colors.white24, fontSize: 14),
          ),
          dropdownColor: const Color(0xFF1A1A1A),
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF06B6D4)),
          items: items
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Text(m, style: const TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedTarget = val),
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
    return TextField(
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 11),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white10, fontSize: 14),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF06B6D4).withOpacity(0.5),
          size: 20,
        ),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildMetricSelector() {
    final metrics = [
      "Quilometragem Total",
      "Maior Velocidade",
      "Consistência (Dias)",
      "Melhor Pace Médio",
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMetric,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A1A),
          icon: const Icon(Icons.analytics_outlined, color: Color(0xFF06B6D4)),
          items: metrics
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Text(
                    m,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedMetric = val!),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF06B6D4),
                onPrimary: Colors.black,
                surface: Color(0xFF1A1A1A),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _selectedDateRange = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF06B6D4),
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              _selectedDateRange == null
                  ? "Definir Janela de Tempo"
                  : "${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} até ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}",
              style: TextStyle(
                color: _selectedDateRange == null
                    ? Colors.white24
                    : Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: Color(0xFF06B6D4),
            size: 30,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "RECOMPENSA DE MÉRITO",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "Badge exclusivo + 500 XP",
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (v) {},
            activeColor: const Color(0xFF06B6D4),
          ),
        ],
      ),
    );
  }

  Widget _buildLaunchButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Experimento Coletivo Disparado!"),
              backgroundColor: Color(0xFF06B6D4),
            ),
          );
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          "LANÇAR DESAFIO",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
