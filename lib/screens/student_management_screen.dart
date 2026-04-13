import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para copiar o link

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  // Lista fake para exemplo
  final List<Map<String, dynamic>> groups = [
    {"name": "Elite Sprint", "desc": "Foco em explosão e 100m", "count": 8},
    {
      "name": "Maratonistas Z2",
      "desc": "Treinos de endurance leve",
      "count": 15,
    },
  ];

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
      body: SingleChildScrollView(
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
                  "TODAS AS COBAIAS",
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
            _buildAllStudentsList(),
          ],
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
            onLongPress: () => _showEditDeleteGroupOptions(
              context,
              group,
            ), // Opções ao segurar
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

  Widget _buildAllStudentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white10,
              child: Icon(Icons.person, color: Colors.white38),
            ),
            title: Text(
              "Atleta Cobaia #0$index",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              "Plano Pro • Última atividade: Hoje",
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.white24),
              color: const Color(0xFF1A1A1A),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'remove',
                  child: Text(
                    "Remover Aluno",
                    style: TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ),
              ],
              onSelected: (val) {
                if (val == 'remove')
                  _confirmDelete(context, "Atleta Cobaiaa #0$index");
              },
            ),
          ),
        );
      },
    );
  }

  // DIÁLOGO PARA GERAR LINK DE CONVITE
  void _showInviteLinkDialog(BuildContext context) {
    const String inviteLink = "https://fitlab.app/invite/coach-joao-123";
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
              "Compartilhe o link abaixo para que o atleta se vincule ao seu laboratório.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                inviteLink,
                style: TextStyle(color: Color(0xFF06B6D4), fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: inviteLink));
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

  // MODAL PARA EDITAR OU EXCLUIR TURMA
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
              _confirmDelete(context, group['name']);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // MODAL UNIFICADO PARA CRIAR/EDITAR TURMA
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

  void _confirmDelete(BuildContext context, String targetName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          "CONFIRMAR EXCLUSÃO",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Deseja realmente remover '$targetName'? Esta ação não pode ser desfeita.",
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
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "EXCLUIR",
              style: TextStyle(color: Colors.redAccent),
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
