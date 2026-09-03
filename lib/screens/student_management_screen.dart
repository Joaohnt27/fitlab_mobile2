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
  // Lista de Turmas fake para exemplo (Será real no futuro)
  final List<Map<String, dynamic>> groups = [];

  // 👇 DADOS REAIS DO BACKEND 👇
  List<dynamic> _alunos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarAlunos();
  }

  // BUSCA OS ALUNOS VINCULADOS AO TREINADOR
  Future<void> _carregarAlunos() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idCoach = userProvider.usuarioLogado?.id;
    if (idCoach == null) return;

    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/mentorias/treinador/$idCoach/alunos',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _alunos = json.decode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Erro ao carregar alunos: $e");
      setState(() => _isLoading = false);
    }
  }

  // FUNÇÃO DE REMOVER O VÍNCULO DO ALUNO
  Future<void> _removerAluno(int idVinculo, String nomeAluno) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/mentorias/$idVinculo/recusar',
      ); // ou /remover dependendo do seu java
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$nomeAluno foi removido da sua assessoria."),
              backgroundColor: const Color(0xFF06B6D4),
            ),
          );
        }
        _carregarAlunos(); // Recarrega a lista

        // Atualiza os dados do Treinador no App (Saldo, contagens, etc)
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
        onRefresh: _carregarAlunos,
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
              _buildGroupsList(),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader(
                    "TODAS AS COBAIAS (${_alunos.length})",
                    Icons.person_search_rounded,
                  ),
                  // BOTÃO ADICIONAR ALUNO (GERAR LINK)
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
        onPressed: () => _showGroupModal(context),
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
          hintText: "Buscar aluno por nome ou ID...",
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
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
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
                          group['name'],
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
                          Icons.edit_note,
                          color: Colors.white24,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  Text(
                    group['desc'],
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

  // 👇 LISTA DE ALUNOS REAIS COM IDENTIFICAÇÃO DE ELITE VS ASSESSORIA 👇
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
              // Destaca a borda se for Elite App
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
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    aluno['nome'] ?? "Atleta",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Contrato Ativo: Atletas Elite não podem ser removidos durante os 30 dias de vigência.",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.amber,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
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
                      if (val == 'remove') {
                        _confirmDelete(
                          context,
                          aluno['idVinculo'],
                          aluno['nome'],
                        );
                      }
                    },
                  ),
          ),
        );
      },
    );
  }

  // DIÁLOGO PARA GERAR LINK DE CONVITE (Será real no futuro)
  void _showInviteLinkDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String coachCode =
        userProvider.usuarioLogado?.codigoAmizade ?? "ERROR";
    final String inviteLink = "$coachCode";

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
              "Seu aluno da vida real pode ingressar sem pagar a assinatura da Mentoria. Compartilhe seu código com ele:",
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
              Clipboard.setData(ClipboardData(text: inviteLink));
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Link copiado!")));
            },
            child: const Text(
              "COPIAR LINK",
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
            title: Text(
              "Editar ${group['name']}",
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _showGroupModal(context, existingGroup: group);
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
              // Lógica de exclusão de turma no futuro
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showGroupModal(BuildContext context, {Map? existingGroup}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              existingGroup == null ? "NOVA TURMA" : "EDITAR TURMA",
              style: const TextStyle(
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildField("Nome da Turma", "Ex: Velocistas 2026"),
            const SizedBox(height: 16),
            _buildField(
              "Descrição Específica",
              "Descreva o objetivo científico desta turma...",
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
  }

  // 👇 DIALOG ATUALIZADO PARA EXCLUIR ALUNO REAL DO BANCO 👇
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
          "Deseja realmente remover '$targetName' da sua assessoria? O vínculo de treinos será quebrado.",
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
              _removerAluno(idVinculo, targetName); // Chama a exclusão real
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

  Widget _buildField(String label, String hint) {
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
