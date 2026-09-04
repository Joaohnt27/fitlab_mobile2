import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../config/api_constants.dart';
import '../utils/plan_permissions.dart';
import 'challenge_history_screen.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  int _targetType = 1; // Default para Turma
  String? _selectedTargetId;
  String _selectedMetric = "Quilometragem Total";
  DateTimeRange? _selectedDateRange;
  double _xpRecompensa = 50;
  bool _isPublico = false;
  List<Map<String, dynamic>> _meusAlunos = [];
  List<Map<String, dynamic>> _minhasTurmas = [];
  bool _isLoading = true;

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _objetivoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _objetivoController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idCoach = userProvider.usuarioLogado?.id;
    if (idCoach == null) return;

    try {
      final urlAlunos = Uri.parse(
        '${ApiConstants.baseUrl}/mentorias/treinador/$idCoach/alunos',
      );
      final urlTurmas = Uri.parse(
        '${ApiConstants.baseUrl}/turmas/treinador/$idCoach',
      );

      final responseAlunos = await http.get(urlAlunos);
      final responseTurmas = await http.get(urlTurmas);

      if (mounted) {
        setState(() {
          if (responseAlunos.statusCode == 200) {
            _meusAlunos = List<Map<String, dynamic>>.from(
              json
                  .decode(utf8.decode(responseAlunos.bodyBytes))
                  .map(
                    (a) => {"id": a['idAtleta'].toString(), "nome": a['nome']},
                  ),
            );
          }
          if (responseTurmas.statusCode == 200) {
            _minhasTurmas = List<Map<String, dynamic>>.from(
              json
                  .decode(utf8.decode(responseTurmas.bodyBytes))
                  .map(
                    (t) => {
                      "id": t['id'].toString(),
                      "nome": t['nome'],
                      "count": t['count'],
                    },
                  ),
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _dispararDesafio() async {
    if (!_isPublico && _selectedTargetId == null) {
      _showError("Selecione o alvo ou marque o desafio como Público.");
      return;
    }
    if (_tituloController.text.trim().isEmpty ||
        _objetivoController.text.trim().isEmpty) {
      _showError("Preencha título e objetivo do desafio.");
      return;
    }
    if (_selectedDateRange == null) {
      _showError("Defina o prazo do desafio.");
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idTreinador = userProvider.usuarioLogado?.id;

    final payload = {
      "titulo": _tituloController.text.trim(),
      "descricao": _objetivoController.text.trim(),
      "metrica": _selectedMetric,
      "recompensaXp": _xpRecompensa.toInt(),
      "isPublico": _isPublico,
      "dataInicio": _selectedDateRange!.start.toIso8601String(),
      "dataFim": _selectedDateRange!.end.toIso8601String(),
      "tipoAlvo": _isPublico
          ? "PUBLICO"
          : (_targetType == 0 ? "INDIVIDUAL" : "TURMA"),
      "alvoId": _isPublico ? null : int.parse(_selectedTargetId!),
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/desafios/treinador/$idTreinador/criar',
        ),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(payload),
      );

      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Experimento Coletivo Disparado! 🏆"),
            backgroundColor: Color(0xFF06B6D4),
          ),
        );
        Navigator.pop(context);
      } else {
        _showError("Erro: ${response.body}");
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showError("Falha de conexão com a API.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final planoObj = userProvider.usuarioLogado?.plano;
    final permissions = PlanPermissions(planoObj?['nome'] ?? "START");

    // Limite de XP dinâmico: Pro = 100, Elite = 200
    final double maxXP = permissions.isElite ? 200.0 : 100.0;
    if (_xpRecompensa > maxXP) _xpRecompensa = maxXP;

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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChallengeHistoryScreen(),
              ),
            ),
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
            if (permissions.canCreatePublicChallenges) ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: SwitchListTile(
                  title: const Text(
                    "Desafio Público Global",
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: const Text(
                    "Visível no Marketplace para atrair novos atletas.",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  activeColor: Colors.black,
                  activeTrackColor: Colors.amber,
                  value: _isPublico,
                  onChanged: (val) => setState(() {
                    _isPublico = val;
                    if (val)
                      _selectedTargetId = null; // Zera o alvo se ficar público
                  }),
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (!_isPublico) ...[
              _buildSectionLabel("CANAL DE DISPARO"),
              const SizedBox(height: 16),
              _buildTypeSelector(),
              const SizedBox(height: 20),
              _buildTargetDropdown(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Divider(color: Colors.white10),
              ),
            ],

            _buildSectionLabel("IDENTIFICAÇÃO DO EXPERIMENTO"),
            const SizedBox(height: 20),
            _buildInputField(
              "Título do Desafio",
              "Ex: Sprint de Outono",
              Icons.emoji_events_outlined,
              controller: _tituloController,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              "Objetivo Científico",
              "Ex: Testar resistência em subida...",
              Icons.biotech_outlined,
              maxLines: 3,
              controller: _objetivoController,
            ),

            const SizedBox(height: 32),
            _buildSectionLabel("METODOLOGIA E PRAZO"),
            const SizedBox(height: 20),
            _buildMetricSelector(),
            const SizedBox(height: 20),
            _buildDatePicker(context),

            const SizedBox(height: 32),
            _buildSectionLabel("RECOMPENSA DE EXPERIÊNCIA"),
            const SizedBox(height: 16),

            // SLIDER DE XP DINÂMICO 
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.stars_rounded, color: Color(0xFF06B6D4)),
                          SizedBox(width: 8),
                          Text(
                            "XP Distribuído",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${_xpRecompensa.toInt()} XP",
                        style: const TextStyle(
                          color: Color(0xFF06B6D4),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _xpRecompensa,
                    min: 10,
                    max: maxXP, 
                    divisions: (maxXP / 10).toInt() - 1,
                    activeColor: const Color(0xFF06B6D4),
                    inactiveColor: Colors.white10,
                    label: "${_xpRecompensa.toInt()}",
                    onChanged: (val) => setState(() => _xpRecompensa = val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Min: 10 XP",
                        style: TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                      Text(
                        permissions.isElite
                            ? "Max: 200 XP (Elite)"
                            : "Max: 100 XP (Pro)",
                        style: TextStyle(
                          color: permissions.isElite
                              ? Colors.amber
                              : const Color(0xFF06B6D4),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
          _selectedTargetId = null;
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
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
      );

    if (_targetType == 1) {
      if (_minhasTurmas.isEmpty) return _buildEmptyBox("Nenhuma turma criada.");
      return _renderDropdown(
        items: _minhasTurmas
            .map(
              (t) => DropdownMenuItem<String>(
                value: t["id"],
                child: Text("${t["nome"]} (${t["count"]})"),
              ),
            )
            .toList(),
        hint: "Escolher Turma...",
      );
    }

    if (_targetType == 0 && _meusAlunos.isEmpty)
      return _buildEmptyBox("Nenhum aluno ativo.");
    return _renderDropdown(
      items: _meusAlunos
          .map(
            (aluno) => DropdownMenuItem<String>(
              value: aluno["id"],
              child: Text(aluno["nome"]),
            ),
          )
          .toList(),
      hint: "Escolher Aluno...",
    );
  }

  Widget _buildEmptyBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white38)),
    );
  }

  Widget _renderDropdown({
    required List<DropdownMenuItem<String>> items,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTargetId,
          hint: Text(
            hint,
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
          items: items,
          onChanged: (val) => setState(() => _selectedTargetId = val),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    IconData icon, {
    int maxLines = 1,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
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
        onPressed: _dispararDesafio,
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
