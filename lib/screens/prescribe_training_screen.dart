import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../config/api_constants.dart';
import '../utils/plan_permissions.dart';
import 'prescription_history_screen.dart';
import 'subscription_screen.dart';

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
  List<Map<String, dynamic>> _minhasTurmas = []; 
  bool _isLoadingAlunos = true;
  bool _isLoadingTurmas = true; 
  bool _isSavingTemplate = false;

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _protocoloController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _buscarMeusAlunos();
    _buscarMinhasTurmas(); 
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _volumeController.dispose();
    _protocoloController.dispose();
    super.dispose();
  }

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

  Future<void> _buscarMinhasTurmas() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idCoach = userProvider.usuarioLogado?.id;
    if (idCoach == null) return;

    final url = Uri.parse('${ApiConstants.baseUrl}/turmas/treinador/$idCoach');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> dados = json.decode(
          utf8.decode(response.bodyBytes),
        );
        setState(() {
          _minhasTurmas = dados
              .map(
                (t) => {
                  "id": t['id'].toString(),
                  "nome": t['nome'],
                  "count": t['count'],
                },
              )
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar turmas: $e");
    } finally {
      setState(() => _isLoadingTurmas = false);
    }
  }

  Future<void> _salvarComoTemplate() async {
    if (_tituloController.text.trim().isEmpty ||
        _volumeController.text.trim().isEmpty ||
        _protocoloController.text.trim().isEmpty) {
      _showError("Preencha todos os parâmetros técnicos para salvar o molde.");
      return;
    }
    setState(() => _isSavingTemplate = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idTreinador = userProvider.usuarioLogado?.id;

    final payload = {
      "titulo": _tituloController.text.trim(),
      "volume": _volumeController.text.trim(),
      "descricao": _protocoloController.text.trim(),
      "treinadorId": idTreinador,
    };

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/templates'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Template salvo na biblioteca! 📂"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError("Erro ao salvar template.");
      }
    } catch (e) {
      _showError("Falha de conexão com a biblioteca.");
    } finally {
      setState(() => _isSavingTemplate = false);
    }
  }

  Future<void> _abrirBiblioteca() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idTreinador = userProvider.usuarioLogado?.id;
    if (idTreinador == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
      ),
    );

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/templates/treinador/$idTreinador'),
      );
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final List<dynamic> templates = json.decode(
          utf8.decode(response.bodyBytes),
        );
        _mostrarModalBiblioteca(templates);
      } else {
        _showError("Erro ao buscar biblioteca.");
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showError("Falha de conexão.");
    }
  }

  Future<void> _deletarTemplate(
    int idTemplate,
    StateSetter setModalState,
    List<dynamic> templates,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/templates/$idTemplate'),
      );
      if (response.statusCode == 200) {
        setModalState(() {
          templates.removeWhere((t) => t['id'] == idTemplate);
        });
      }
    } catch (e) {
      debugPrint("Erro ao deletar: $e");
    }
  }

  void _mostrarModalBiblioteca(List<dynamic> templates) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "BIBLIOTECA DE TREINOS",
                    style: TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Selecione um molde salvo para autopreencher os campos.",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  if (templates.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Sua biblioteca está vazia.",
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: templates.length,
                        itemBuilder: (context, index) {
                          final t = templates[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Material(
                              color: Colors.black,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  t['titulo'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Volume: ${t['volume']}",
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _tituloController.text = t['titulo'];
                                    _volumeController.text = t['volume'];
                                    _protocoloController.text = t['descricao'];
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Template carregado!"),
                                      backgroundColor: Color(0xFF06B6D4),
                                    ),
                                  );
                                },
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () => _deletarTemplate(
                                    t['id'],
                                    setModalState,
                                    templates,
                                  ),
                                ),
                              ),
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
      },
    );
  }

  void _mostrarPaywallBiblioteca() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.folder_off_outlined,
              color: Colors.amber,
              size: 56,
            ),
            const SizedBox(height: 24),
            const Text(
              "FUNCIONALIDADE FECHADA",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "A Biblioteca de Treinos é exclusiva dos planos PRO e ELITE.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "CONHECER PLANOS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dispararProtocolo() async {
    if (_selectedTargetId == null) {
      _showError("Selecione o receptor do treino.");
      return;
    }
    if (_tituloController.text.trim().isEmpty ||
        _volumeController.text.trim().isEmpty) {
      _showError("Preencha o título e o volume do treino.");
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idTreinador = userProvider.usuarioLogado?.id;

    final payload = {
      "treinadorId": idTreinador,
      "alvoId": int.parse(
        _selectedTargetId!,
      ), // Pode ser ID do Atleta ou ID da Turma!
      "tipoAlvo": _targetType == 0 ? "INDIVIDUAL" : "TURMA",
      "titulo": _tituloController.text.trim(),
      "volume": _volumeController.text.trim(),
      "descricao": _protocoloController.text.trim(),
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
        Uri.parse('${ApiConstants.baseUrl}/treinos/prescrever'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(payload),
      );

      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        _showSuccessFeedback();
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
              "Treino enviado com sucesso!",
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
    final userProvider = Provider.of<UserProvider>(context);
    final planoObj = userProvider.usuarioLogado?.plano;
    final permissions = PlanPermissions(planoObj?['nome'] ?? "START");

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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrescriptionHistoryScreen(),
              ),
            ),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel("PARÂMETROS TÉCNICOS"),
                InkWell(
                  onTap: permissions.canUseLibrary
                      ? _abrirBiblioteca
                      : _mostrarPaywallBiblioteca,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          permissions.canUseLibrary
                              ? Icons.folder_open_rounded
                              : Icons.lock_outline,
                          color: permissions.canUseLibrary
                              ? const Color(0xFF06B6D4)
                              : Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "IMPORTAR",
                          style: TextStyle(
                            color: permissions.canUseLibrary
                                ? const Color(0xFF06B6D4)
                                : Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _isSavingTemplate
                    ? null
                    : (permissions.canUseLibrary
                          ? _salvarComoTemplate
                          : _mostrarPaywallBiblioteca),
                icon: _isSavingTemplate
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ),
                      )
                    : Icon(
                        permissions.canUseLibrary
                            ? Icons.bookmark_add_outlined
                            : Icons.lock_outline,
                        size: 18,
                      ),
                label: Text(
                  permissions.canUseLibrary
                      ? "SALVAR COMO TEMPLATE"
                      : "BIBLIOTECA BLOQUEADA",
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: permissions.canUseLibrary
                      ? Colors.white54
                      : Colors.amber,
                  side: BorderSide(
                    color: permissions.canUseLibrary
                        ? Colors.white10
                        : Colors.amber.withOpacity(0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
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
          _selectedTargetId = null;
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
    if ((_isLoadingAlunos && _targetType == 0) ||
        (_isLoadingTurmas && _targetType == 1)) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
      );
    }

    if (_targetType == 1) {
      if (_minhasTurmas.isEmpty) {
        return _buildEmptyBox("Você ainda não criou nenhuma turma.");
      }
      return _renderDropdown(
        items: _minhasTurmas
            .map(
              (t) => DropdownMenuItem<String>(
                value: t["id"],
                child: Text(
                  "${t["nome"]} (${t["count"]} alunos)",
                ), // Mostra o nome e a qtd de alunos
              ),
            )
            .toList(),
        hint: "Escolher Turma...",
      );
    }

    if (_targetType == 0 && _meusAlunos.isEmpty) {
      return _buildEmptyBox("Você ainda não tem alunos ativos.");
    }

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
