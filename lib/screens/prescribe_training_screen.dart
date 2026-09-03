import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../config/api_constants.dart';
import 'prescription_history_screen.dart';

class PrescribeTrainingScreen extends StatefulWidget {
  const PrescribeTrainingScreen({super.key});

  @override
  State<PrescribeTrainingScreen> createState() =>
      _PrescribeTrainingScreenState();
}

class _PrescribeTrainingScreenState extends State<PrescribeTrainingScreen> {
  int _targetType = 0; // 0 para Individual, 1 para Turma
  String? _selectedTargetId;

  List<Map<String, dynamic>> _meusAlunos = [];
  bool _isLoadingAlunos = true;

  // Controladores dos campos de texto
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _protocoloController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _buscarMeusAlunos();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _volumeController.dispose();
    _protocoloController.dispose();
    super.dispose();
  }

  // BUSCA OS ALUNOS VINCULADOS AO TREINADOR
  Future<void> _buscarMeusAlunos() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idCoach = userProvider.usuarioLogado?.id;
    if (idCoach == null) return;

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/mentorias/treinador/$idCoach/alunos',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> dados = json.decode(
          utf8.decode(response.bodyBytes),
        );
        setState(() {
          _meusAlunos = dados
              .map((a) => {"id": a['idAtleta'].toString(), "nome": a['nome']})
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar alunos: $e");
    } finally {
      setState(() => _isLoadingAlunos = false);
    }
  }

  // ENVIA O TREINO PARA O BACK-END
  // ENVIA O TREINO PARA O BACK-END
  Future<void> _dispararProtocolo() async {
    // 1. Validações Básicas
    if (_selectedTargetId == null && _targetType == 0) {
      _showError("Selecione um aluno alvo.");
      return;
    }
    if (_tituloController.text.trim().isEmpty) {
      _showError("Dê um nome para a identificação do treino.");
      return;
    }
    if (_volumeController.text.trim().isEmpty) {
      _showError("Insira a carga do treino.");
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idTreinador = userProvider.usuarioLogado?.id;

    // 2. Construindo o Payload para casar com o DTO do Java
    final payload = {
      "treinadorId": idTreinador,
      "alvoId": int.parse(
        _selectedTargetId!,
      ), // Converte a String do Dropdown para int
      "tipoAlvo": _targetType == 0 ? "INDIVIDUAL" : "TURMA",
      "titulo": _tituloController.text.trim(),
      "volume": _volumeController.text.trim(),
      "descricao": _protocoloController.text.trim(),
    };

    // Abre o loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
      ),
    );

    // 3. Disparo HTTP para o Spring Boot
    final url = Uri.parse('${ApiConstants.baseUrl}/treinos/prescrever');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(payload),
      );

      if (context.mounted) Navigator.pop(context); // Fecha o loading

      if (response.statusCode == 200) {
        _showSuccessFeedback();

        // Volta para o Dashboard após 2 segundos
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) Navigator.pop(context);
        });
      } else {
        _showError("Erro ao enviar prescrição: ${response.body}");
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showError("Falha de conexão com o laboratório.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
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
              controller: _tituloController,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              "Volume da Carga",
              "Ex: 12km ou 45 min",
              Icons.timer_outlined,
              controller: _volumeController,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              "Protocolo de Execução",
              "Descreva a intensidade, pace e intervalos...",
              Icons.subject_rounded,
              maxLines: 5,
              controller: _protocoloController,
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
          _selectedTargetId =
              null; // Reseta o aluno selecionado ao trocar de aba
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
    if (_isLoadingAlunos && _targetType == 0) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
      );
    }

    // Se for Turma (Mockado por enquanto)
    if (_targetType == 1) {
      List<String> turmas = [
        "Elite Sprint",
        "Maratonistas Z2",
        "Iniciantes Lab",
        "Triathlon Team",
      ];
      return _renderDropdown(
        items: turmas
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        hint: "Escolher Turma...",
      );
    }

    // Se for Atleta Individual e não tiver nenhum aluno
    if (_targetType == 0 && _meusAlunos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "Você ainda não tem alunos ativos.",
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    // Dropdown Real puxando da API
    return _renderDropdown(
      items: _meusAlunos.map((aluno) {
        return DropdownMenuItem<String>(
          value: aluno["id"],
          child: Text(aluno["nome"]),
        );
      }).toList(),
      hint: "Escolher Aluno...",
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
          onChanged: (newValue) => setState(() => _selectedTargetId = newValue),
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
          controller: controller,
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
        onPressed: _dispararProtocolo,
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
}
