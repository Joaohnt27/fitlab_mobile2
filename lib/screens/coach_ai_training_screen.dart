import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../config/api_constants.dart';

class CoachAITrainingScreen extends StatefulWidget {
  const CoachAITrainingScreen({super.key});

  @override
  State<CoachAITrainingScreen> createState() => _CoachAITrainingScreenState();
}

class _CoachAITrainingScreenState extends State<CoachAITrainingScreen> {
  bool _isProcessing = false;

  // Variáveis de Estado do Formulário
  String? _selectedObjective;
  String? _selectedAge;
  String? _selectedLevel;
  String? _selectedDistance;
  String? _selectedFrequency;
  String? _selectedDuration;

  // Listas de Opções
  final List<String> _objectives = [
    "Melhorar resistência",
    "Aumentar velocidade",
    "Melhorar desempenho em provas",
    "Melhorar tempo/pace",
    "Preparação para distância específica",
    "Retorno gradual aos treinos",
    "Manutenção de Saúde",
  ];
  final List<String> _ages = [
    "18–25 anos",
    "26–35 anos",
    "36–45 anos",
    "46–55 anos",
    "Acima de 55 anos",
  ];
  final List<String> _levels = [
    "Iniciante",
    "Intermediário",
    "Avançado",
    "Elite",
  ];
  final List<String> _distances = [
    "5 km",
    "10 km",
    "15 km",
    "21 km (Meia)",
    "42 km (Maratona)",
    "Sem distância definida",
  ];
  final List<String> _frequencies = [
    "2 vezes por semana",
    "3 vezes por semana",
    "4 vezes por semana",
    "5 vezes por semana",
    "6 vezes por semana",
    "Todos os dias",
  ];
  final List<String> _durations = [
    "4 semanas",
    "8 semanas",
    "12 semanas",
    "16 semanas",
  ];

  Future<void> _gerarTreinoIA() async {
    // 1. Validação
    if (_selectedObjective == null ||
        _selectedAge == null ||
        _selectedLevel == null ||
        _selectedDistance == null ||
        _selectedFrequency == null ||
        _selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os parâmetros da IA."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. Monta o Prompt Estruturado
    String promptMontado =
        '''
      Objetivo principal: $_selectedObjective
      Faixa Etária dos Atletas: $_selectedAge
      Nível de Experiência: $_selectedLevel
      Distância Alvo / Prova: $_selectedDistance
      Frequência Semanal: $_selectedFrequency
      Duração do Ciclo (Planejamento): $_selectedDuration
    ''';

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idTreinador = userProvider.usuarioLogado?.id;

    if (idTreinador == null) return;

    setState(() => _isProcessing = true);

    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/ia/treinadores/$idTreinador/sintetizar',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({"prompt_estruturado": promptMontado}),
      );

      setState(() => _isProcessing = false);

      if (response.statusCode == 200) {
        // A API retorna a String em formato JSON gerada pelo Gemini
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        _showResultModal(jsonResponse);
      } else {
        final errorMsg =
            json.decode(utf8.decode(response.bodyBytes))['erro'] ??
            "Erro desconhecido";
        _showError(errorMsg);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError("Falha ao comunicar com o servidor da IA.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAIPromptHeader(),
                const SizedBox(height: 32),

                _buildSectionLabel("1. QUAL OBJETIVO DESEJA ATINGIR?"),
                const SizedBox(height: 12),
                _buildDropdown(
                  hint: "Selecione o objetivo...",
                  value: _selectedObjective,
                  items: _objectives,
                  onChanged: (val) => setState(() => _selectedObjective = val),
                ),
                const SizedBox(height: 24),

                _buildSectionLabel("2. NÍVEL DOS ATLETAS"),
                const SizedBox(height: 12),
                _buildDropdown(
                  hint: "Ex: Intermediário",
                  value: _selectedLevel,
                  items: _levels,
                  onChanged: (val) => setState(() => _selectedLevel = val),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("3. FAIXA ETÁRIA"),
                          const SizedBox(height: 12),
                          _buildDropdown(
                            hint: "Ex: 26-35",
                            value: _selectedAge,
                            items: _ages,
                            onChanged: (val) =>
                                setState(() => _selectedAge = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("4. DISTÂNCIA"),
                          const SizedBox(height: 12),
                          _buildDropdown(
                            hint: "Ex: 10 km",
                            value: _selectedDistance,
                            items: _distances,
                            onChanged: (val) =>
                                setState(() => _selectedDistance = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("5. FREQUÊNCIA"),
                          const SizedBox(height: 12),
                          _buildDropdown(
                            hint: "Dias por semana",
                            value: _selectedFrequency,
                            items: _frequencies,
                            onChanged: (val) =>
                                setState(() => _selectedFrequency = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("6. DURAÇÃO"),
                          const SizedBox(height: 12),
                          _buildDropdown(
                            hint: "Semanas totais",
                            value: _selectedDuration,
                            items: _durations,
                            onChanged: (val) =>
                                setState(() => _selectedDuration = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                _buildGenerateButton(),
                const SizedBox(height: 40),
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
          SizedBox(width: 16),
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
                  "Preencha os parâmetros para a IA gerar a estrutura perfeita de treinamento.",
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
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.white24, fontSize: 13),
          ),
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A1A),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF06B6D4),
          ),
          items: items
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    s,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
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
        onPressed: _gerarTreinoIA,
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
                "PROCESSANDO PARÂMETROS...",
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

  // 👇 MODAL QUE EXIBE O TREINO GERADO 👇
  void _showResultModal(Map<String, dynamic> treinoJson) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height *
              0.75, // Ocupa 75% da tela para caber tudo
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "PROPOSTA DA IA",
                style: TextStyle(
                  color: Color(0xFF06B6D4),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                treinoJson['titulo'] ?? "Plano de Treinamento",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                treinoJson['foco'] ?? "Sem foco definido",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "AQUECIMENTO PADRÃO",
                          style: TextStyle(
                            color: Color(0xFF06B6D4),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (treinoJson['aquecimento'] != null)
                          ...(treinoJson['aquecimento'] as List).map(
                            (a) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                "• $a",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: Colors.white10),
                        ),

                        const Text(
                          "ROTINA DE TREINOS",
                          style: TextStyle(
                            color: Color(0xFF06B6D4),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (treinoJson['dias'] != null)
                          ...(treinoJson['dias'] as List).map(
                            (dia) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dia['dia'] ?? "Dia",
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        "${dia['distancia_km']} km",
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    dia['descricao'] ?? "",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "FECHAR",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "O treino já está salvo na sua Biblioteca! 📚",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Futuro: Redirecionar para a tela da biblioteca de treinos
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06B6D4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "VER BIBLIOTECA",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
