import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:fitlab_mobile2/config/api_constants.dart';
import 'package:fitlab_mobile2/providers/user_provider.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  List<dynamic> _alunos = [];
  List<dynamic> _turmas = [];
  bool _isLoading = true;

  final TextEditingController _nomeTurmaController = TextEditingController();
  final TextEditingController _descTurmaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _nomeTurmaController.dispose();
    _descTurmaController.dispose();
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
            _alunos = json.decode(utf8.decode(responseAlunos.bodyBytes));
          }
          if (responseTurmas.statusCode == 200) {
            _turmas = json.decode(utf8.decode(responseTurmas.bodyBytes));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 👇 SALVAR TURMA AGORA ACEITA ID (PARA SABER SE É PUT OU POST) 👇
  Future<void> _salvarTurma(
    List<int> atletasSelecionados, {
    int? idTurmaExistente,
  }) async {
    if (_nomeTurmaController.text.trim().isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idCoach = userProvider.usuarioLogado?.id;

    final payload = {
      "nome": _nomeTurmaController.text.trim(),
      "descricao": _descTurmaController.text.trim(),
      "treinadorId": idCoach,
      "atletasIds": atletasSelecionados,
    };

    Navigator.pop(context); // Fecha o modal

    try {
      http.Response response;

      // SE TEM ID, É UMA EDIÇÃO (PUT)
      if (idTurmaExistente != null) {
        response = await http.put(
          Uri.parse('${ApiConstants.baseUrl}/turmas/$idTurmaExistente'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: json.encode(payload),
        );
      } else {
        // SE NÃO TEM ID, É CRIAÇÃO (POST)
        response = await http.post(
          Uri.parse('${ApiConstants.baseUrl}/turmas'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: json.encode(payload),
        );
      }

      if (response.statusCode == 200) {
        _nomeTurmaController.clear();
        _descTurmaController.clear();
        _carregarDados();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                idTurmaExistente == null
                    ? "Turma sintetizada com sucesso!"
                    : "Turma atualizada!",
              ),
              backgroundColor: const Color(0xFF06B6D4),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Erro ao salvar turma: $e");
    }
  }

  Future<void> _excluirTurma(int idTurma) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/turmas/$idTurma'),
      );
      if (response.statusCode == 200) {
        _carregarDados();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Turma excluída."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Erro ao excluir turma: $e");
    }
  }

  Future<void> _removerAluno(int idVinculo, String nomeAluno) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/mentorias/$idVinculo/recusar',
      );
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$nomeAluno foi removido."),
              backgroundColor: const Color(0xFF06B6D4),
            ),
          );
        }
        _carregarDados();
        if (context.mounted) {
          await Provider.of<UserProvider>(
            context,
            listen: false,
          ).recarregarUsuario();
        }
      }
    } catch (e) {
      debugPrint("Erro ao remover aluno: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "GESTÃO DE ALUNOS",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF06B6D4),
        backgroundColor: const Color(0xFF1A1A1A),
        onRefresh: _carregarDados,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 32),

              _buildSectionHeader("TURMAS ATIVAS", Icons.group_work_rounded),
              const SizedBox(height: 16),

              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF06B6D4),
                      ),
                    )
                  : _buildGroupsList(),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader(
                    "TODAS AS COBAIAS (${_alunos.length})",
                    Icons.person_search_rounded,
                  ),
                  TextButton.icon(
                    onPressed: () => _showInviteLinkDialog(context),
                    icon: const Icon(
                      Icons.link,
                      size: 18,
                      color: Color(0xFF06B6D4),
                    ),
                    label: const Text(
                      "ADICIONAR ALUNO",
                      style: TextStyle(
                        color: Color(0xFF06B6D4),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF06B6D4),
                      ),
                    )
                  : _buildAllStudentsList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGroupModal(context), // Abre vazio (Criação)
        backgroundColor: const Color(0xFF06B6D4),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          "CRIAR TURMA",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Color(0xFF06B6D4)),
          hintText: "Buscar aluno...",
          hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF06B6D4), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupsList() {
    if (_turmas.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.02)),
        ),
        child: const Text(
          "Nenhuma turma ativa.",
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _turmas.length,
        itemBuilder: (context, index) {
          final group = _turmas[index];
          return GestureDetector(
            onLongPress: () => _showEditDeleteGroupOptions(context, group),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF06B6D4).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          group['nome'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _showEditDeleteGroupOptions(context, group),
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white24,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  Text(
                    group['descricao'] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  Text(
                    "${group['count']} alunos",
                    style: const TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllStudentsList() {
    if (_alunos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.02)),
        ),
        child: const Column(
          children: [
            Icon(Icons.person_off_outlined, color: Colors.white24, size: 48),
            SizedBox(height: 16),
            Text(
              "Nenhuma cobaia no seu laboratório ainda.",
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _alunos.length,
      itemBuilder: (context, index) {
        final aluno = _alunos[index];
        final bool isElite = aluno['plano'].toString().toUpperCase().contains(
          'ELITE',
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isElite
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.white.withOpacity(0.02),
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white10,
              child: Text(
                aluno['avatar'] ?? "🧪",
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Text(
              aluno['nome'] ?? "Atleta",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  isElite
                      ? Icons.workspace_premium
                      : Icons.fitness_center_rounded,
                  color: isElite ? Colors.amber : Colors.white38,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  isElite ? "Assinante Elite App" : "Aluno de Assessoria",
                  style: TextStyle(
                    color: isElite ? Colors.amber : Colors.white38,
                    fontSize: 11,
                    fontWeight: isElite ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            trailing: isElite
                ? IconButton(
                    icon: const Icon(
                      Icons.lock_outline,
                      color: Colors.amber,
                      size: 20,
                    ),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Atletas Elite não podem ser removidos durante a vigência.",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.amber,
                      ),
                    ),
                  )
                : PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white24),
                    color: const Color(0xFF1A1A1A),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'remove',
                        child: Text(
                          "Remover Aluno",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    onSelected: (val) {
                      if (val == 'remove')
                        _confirmDelete(
                          context,
                          aluno['idVinculo'],
                          aluno['nome'],
                        );
                    },
                  ),
          ),
        );
      },
    );
  }

  void _showInviteLinkDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String coachCode =
        userProvider.usuarioLogado?.codigoAmizade ?? "ERROR";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "CONVIDAR NOVA COBAIA",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Compartilhe seu código com seu aluno real:",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                coachCode,
                style: const TextStyle(
                  color: Color(0xFF06B6D4),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: coachCode));
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Código copiado!")));
            },
            child: const Text(
              "COPIAR",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 👇 OPÇÕES DA TURMA: AGORA COM "EDITAR" 👇
  void _showEditDeleteGroupOptions(BuildContext context, Map group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.white70),
            title: const Text(
              "Editar Turma",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _showGroupModal(
                context,
                existingGroup: group,
              ); // 👈 Abre o modal passando a turma!
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text(
              "Excluir Turma",
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              Navigator.pop(context);
              _excluirTurma(group['id']);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 👇 MODAL DE CRIAÇÃO/EDIÇÃO INTELIGENTE 👇
  void _showGroupModal(BuildContext context, {Map? existingGroup}) {
    // Se for edição, preenche com os dados da turma. Se não, limpa tudo.
    if (existingGroup != null) {
      _nomeTurmaController.text = existingGroup['nome'] ?? "";
      _descTurmaController.text = existingGroup['descricao'] ?? "";
    } else {
      _nomeTurmaController.clear();
      _descTurmaController.clear();
    }

    // Pega os IDs que vieram do banco (agora o Java manda!)
    List<int> selecionados = existingGroup != null
        ? List<int>.from(existingGroup['atletasIds'] ?? [])
        : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existingGroup == null
                        ? "NOVA TURMA"
                        : "EDITAR TURMA", // 👈 Título Dinâmico
                    style: const TextStyle(
                      color: Color(0xFF06B6D4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildField(
                    "Nome da Turma",
                    "Ex: Velocistas 2026",
                    _nomeTurmaController,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    "Descrição Específica",
                    "Descreva o objetivo...",
                    _descTurmaController,
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    "ADICIONAR MEMBROS",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _alunos.isEmpty
                          ? const Center(
                              child: Text(
                                "Sem alunos na assessoria.",
                                style: TextStyle(color: Colors.white38),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _alunos.length,
                              itemBuilder: (context, index) {
                                final aluno = _alunos[index];
                                final int idAtleta = aluno['idAtleta'];

                                return CheckboxListTile(
                                  activeColor: const Color(0xFF06B6D4),
                                  checkColor: Colors.black,
                                  title: Text(
                                    aluno['nome'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  value: selecionados.contains(
                                    idAtleta,
                                  ), // 👈 Se estiver na lista, já vem marcado!
                                  onChanged: (bool? value) {
                                    setModalState(() {
                                      if (value == true) {
                                        selecionados.add(idAtleta);
                                      } else {
                                        selecionados.remove(idAtleta);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      // 👇 Envia o ID para o método saber que é PUT, se existir 👇
                      onPressed: () => _salvarTurma(
                        selecionados,
                        idTurmaExistente: existingGroup?['id'],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06B6D4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        existingGroup == null
                            ? "SINTETIZAR TURMA"
                            : "SALVAR ALTERAÇÕES",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, int idVinculo, String targetName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          "REMOVER ALUNO",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Deseja realmente remover '$targetName' da sua assessoria?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCELAR",
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removerAluno(idVinculo, targetName);
            },
            child: const Text(
              "EXCLUIR",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white12),
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
