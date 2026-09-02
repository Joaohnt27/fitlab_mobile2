import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../config/api_constants.dart';
// 👇 Certifique-se de que o caminho para a tela de detalhes está correto no seu projeto
import '../screens/ai_workout_detail_screen.dart';

class FitLabAICard extends StatefulWidget {
  final Function(Map<String, dynamic>) onGenerate;

  const FitLabAICard({super.key, required this.onGenerate});

  @override
  State<FitLabAICard> createState() => _FitLabAICardState();
}

class _FitLabAICardState extends State<FitLabAICard> {
  // --- VARIÁVEIS DE ESTADO DA API (COTA E HISTÓRICO) ---
  bool _isLoading = true;
  int _limite = 1;
  int _gerados = 0;
  List<dynamic> _historico = [];

  // --- CONTROLADORES DO FORMULÁRIO EXISTENTE ---
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _contextoController = TextEditingController();

  // Valores padrão dos seletores
  String _selectedMeta = "Corrida por Hobby";
  String _selectedPrazo = "3 meses (Foco)";
  String _selectedNivel = "Iniciante";

  @override
  void initState() {
    super.initState();
    _fetchResumoIA(); // Busca a cota ao iniciar
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    _contextoController.dispose();
    super.dispose();
  }

  // 👇 BUSCA OS DADOS DE COTA E HISTÓRICO NO BACKEND 👇
  Future<void> _fetchResumoIA() async {
    final usuario = Provider.of<UserProvider>(
      context,
      listen: false,
    ).usuarioLogado;
    if (usuario == null) return;

    final url = Uri.parse('${ApiConstants.baseUrl}/ia/resumo/${usuario.id}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _limite = data['limite'] ?? 1;
            _gerados = data['gerados'] ?? 0;
            _historico = data['historico'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Erro ao buscar resumo IA: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 👇 BOTTOM SHEET DO HISTÓRICO DE TREINOS 👇
  void _abrirHistorico() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.history, color: Color(0xFF06B6D4)),
                  SizedBox(width: 12),
                  Text(
                    "FÓRMULAS ANTERIORES",
                    style: TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _historico.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          "Nenhuma fórmula sintetizada neste ciclo.",
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),
                    )
                  : ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _historico.length,
                        itemBuilder: (context, index) {
                          final item = _historico[index];
                          final dataCriacao =
                              DateTime.tryParse(item['data_criacao'] ?? '') ??
                              DateTime.now();
                          final dataFormatada =
                              "${dataCriacao.day.toString().padLeft(2, '0')}/${dataCriacao.month.toString().padLeft(2, '0')}/${dataCriacao.year}";

                          return Card(
                            color: Colors.black26,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF06B6D4,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.psychology,
                                  color: Color(0xFF06B6D4),
                                ),
                              ),
                              title: Text(
                                item['titulo'] ?? 'Protocolo IA',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Sintetizado em $dataFormatada",
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white38,
                                size: 14,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                // LÊ O JSON DO BANCO E REABRE A TELA
                                try {
                                  final Map<String, dynamic> treinoData = json
                                      .decode(item['json']);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AIWorkoutDetailScreen(
                                            data: treinoData,
                                          ),
                                    ),
                                  );
                                } catch (e) {
                                  debugPrint("Erro ao ler JSON do banco.");
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  // 👇 SEU FORMULÁRIO PERFEITO MANTIDO INTACTO 👇
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
                  padding: const EdgeInsets.all(2),
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

                              // --- BOTÃO GERAR DENTRO DO MODAL ---
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () {
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

  // --- COMPONENTES DA TELA PRINCIPAL (CARD) ---

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
        ),
      );
    }

    // Calcula o progresso para a barra
    final double progresso = _limite > 0 ? (_gerados / _limite) : 0;
    final bool limiteAtingido = progresso >= 1;

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
          const SizedBox(height: 24),

          // 👇 NOVA BARRA DE PROGRESSO E STATUS 👇
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$_gerados / $_limite",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.psychology, color: Color(0xFF06B6D4), size: 28),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                limiteAtingido ? Colors.redAccent : const Color(0xFF06B6D4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            limiteAtingido
                ? "Limite atingido. Faça upgrade para gerar mais treinos."
                : "Fórmulas utilizadas neste ciclo de cobrança.",
            style: TextStyle(
              color: limiteAtingido ? Colors.redAccent : Colors.white38,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 24),
          _buildButton(limiteAtingido),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
        ),
        // 👇 BOTÃO DE HISTÓRICO ADICIONADO NO CABEÇALHO 👇
        if (_historico.isNotEmpty)
          GestureDetector(
            onTap: _abrirHistorico,
            child: const Text(
              "HISTÓRICO",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildButton(bool limiteAtingido) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: limiteAtingido
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF06B6D4).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton.icon(
        // 👇 O PULO DO GATO: SE O LIMITE ATINGIU, FORÇA O ERRO NO BACKEND E ABRE O PAYWALL
        onPressed: limiteAtingido
            ? () => widget.onGenerate({})
            : _abrirFormularioIA,
        icon: const Icon(Icons.bolt, size: 18),
        label: const Text(
          "CONFIGURAR TREINO",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: limiteAtingido
              ? Colors.white10
              : const Color(0xFF06B6D4),
          foregroundColor: limiteAtingido ? Colors.white38 : Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES (INALTERADOS) ---
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
}
