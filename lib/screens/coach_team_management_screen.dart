import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../config/api_constants.dart';

class CoachTeamManagementScreen extends StatefulWidget {
  const CoachTeamManagementScreen({super.key});

  @override
  State<CoachTeamManagementScreen> createState() =>
      _CoachTeamManagementScreenState();
}

class _CoachTeamManagementScreenState extends State<CoachTeamManagementScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _metricas = {
    "totalTreinadores": 0,
    "totalAlunos": 0,
    "totalTurmas": 0,
  };
  List<dynamic> _coaches = [];
  List<dynamic> _alunosDoLider = []; // Para poder transferir para o staff

  @override
  void initState() {
    super.initState();
    _carregarEquipe();
  }

  Future<void> _carregarEquipe() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idLider = userProvider.usuarioLogado?.id;
    if (idLider == null) return;

    try {
      final urlMetricas = Uri.parse(
        '${ApiConstants.baseUrl}/equipes/lider/$idLider/metricas',
      );
      final urlMembros = Uri.parse(
        '${ApiConstants.baseUrl}/equipes/lider/$idLider/membros',
      );
      final urlAlunos = Uri.parse(
        '${ApiConstants.baseUrl}/mentorias/treinador/$idLider/alunos',
      ); // Alunos da base

      final resMetricas = await http.get(urlMetricas);
      final resMembros = await http.get(urlMembros);
      final resAlunos = await http.get(urlAlunos);

      if (mounted) {
        setState(() {
          if (resMetricas.statusCode == 200) {
            _metricas = json.decode(utf8.decode(resMetricas.bodyBytes));
          }
          if (resMembros.statusCode == 200) {
            _coaches = json.decode(utf8.decode(resMembros.bodyBytes));
          }
          if (resAlunos.statusCode == 200) {
            _alunosDoLider = json.decode(utf8.decode(resAlunos.bodyBytes));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar equipe: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // FUNÇÃO PARA DESVINCULAR STAFF
  Future<void> _desvincularStaff(int idStaff) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/equipes/staff/$idStaff');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Treinador removido da equipe. Alunos realocados para você.",
              ),
              backgroundColor: Color(0xFF06B6D4),
            ),
          );
        }
        _carregarEquipe();
      } else {
        debugPrint("Erro do back-end: ${response.body}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.body),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Erro ao desvincular staff: $e");
    }
  }

  // FUNÇÃO PARA SALVAR TRANSFERÊNCIA DE ALUNOS
  Future<void> _transferirAlunos(int idStaff, List<int> vinculosIds) async {
    Navigator.pop(context); // Fecha o modal
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}/equipes/staff/$idStaff/alunos',
      );
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({"vinculosIds": vinculosIds}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Alunos transferidos com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );
        }
        _carregarEquipe();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Erro ao transferir: $e");
      setState(() => _isLoading = false);
    }
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
          "GESTÃO DE EQUIPE TÉCNICA",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
            )
          : RefreshIndicator(
              color: const Color(0xFF06B6D4),
              backgroundColor: const Color(0xFF1A1A1A),
              onRefresh: _carregarEquipe,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrgOverview(),
                    const SizedBox(height: 32),
                    _buildSectionHeader("TREINADORES ATIVOS"),
                    const SizedBox(height: 16),
                    _buildCoachList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInviteCodeModal(context),
        backgroundColor: const Color(0xFF06B6D4),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.black),
        label: const Text(
          "ADMITIR TREINADOR",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOrgOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _OrgMetric(
            label: "STAFF",
            value: _metricas['totalTreinadores'].toString().padLeft(2, '0'),
          ),
          _OrgMetric(
            label: "ALUNOS TOTAIS",
            value: _metricas['totalAlunos'].toString().padLeft(2, '0'),
          ),
          _OrgMetric(
            label: "TURMAS",
            value: _metricas['totalTurmas'].toString().padLeft(2, '0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF06B6D4),
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildCoachList() {
    if (_coaches.isEmpty) {
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
            Icon(Icons.engineering_outlined, color: Colors.white24, size: 48),
            SizedBox(height: 16),
            Text(
              "Nenhum treinador subordinado na equipe.",
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _coaches.length,
      itemBuilder: (context, index) {
        final coach = _coaches[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF06B6D4).withOpacity(0.1),
              child: const Icon(
                Icons.engineering_rounded,
                color: Color(0xFF06B6D4),
              ),
            ),
            title: Text(
              coach['name'] ?? "Treinador",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "${coach['role']} • ${coach['students']} alunos",
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.white24),
              color: const Color(0xFF1A1A1A),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'atribuir',
                  child: Text(
                    "Atribuir Alunos",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const PopupMenuItem(
                  value: 'remover',
                  child: Text(
                    "Desvincular da Equipe",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              onSelected: (val) {
                if (val == 'atribuir') {
                  _showAssignStudentsModal(context, coach['id'], coach['name']);
                } else if (val == 'remover') {
                  _confirmRemoveStaff(context, coach['id'], coach['name']);
                }
              },
            ),
          ),
        );
      },
    );
  }

  // MODAL PARA ATRIBUIR ALUNOS AO STAFF
  void _showAssignStudentsModal(
    BuildContext context,
    int idStaff,
    String staffName,
  ) {
    List<int> selecionados = [];

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
            padding: const EdgeInsets.only(
              top: 32,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TRANSFERIR ALUNOS",
                    style: TextStyle(
                      color: Color(0xFF06B6D4),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Selecione os atletas que ficarão sob responsabilidade de $staffName.",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _alunosDoLider.isEmpty
                          ? const Center(
                              child: Text(
                                "Você não possui alunos para transferir.",
                                style: TextStyle(color: Colors.white38),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _alunosDoLider.length,
                              itemBuilder: (context, index) {
                                final aluno = _alunosDoLider[index];
                                final int idVinculo = aluno['idVinculo'];

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
                                  value: selecionados.contains(idVinculo),
                                  onChanged: (bool? value) {
                                    setModalState(() {
                                      if (value == true) {
                                        selecionados.add(idVinculo);
                                      } else {
                                        selecionados.remove(idVinculo);
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
                      onPressed: selecionados.isEmpty
                          ? null
                          : () => _transferirAlunos(idStaff, selecionados),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06B6D4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "CONFIRMAR TRANSFERÊNCIA",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  // ALERTA ANTES DE DEMITIR O STAFF
  void _confirmRemoveStaff(
    BuildContext context,
    int idStaff,
    String staffName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          "DESVINCULAR TREINADOR",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Deseja realmente remover $staffName da equipe? Todos os alunos sob responsabilidade dele voltarão para o seu painel central.",
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
              _desvincularStaff(idStaff);
            },
            child: const Text(
              "REMOVER",
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

  void _showInviteCodeModal(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String coachCode =
        userProvider.usuarioLogado?.codigoAmizade ?? "ERRO";

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
          top: 32,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.shield_rounded,
              color: Color(0xFF06B6D4),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "VINCULAR NOVO TREINADOR",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Compartilhe o seu código de Assessoria com o profissional. Ele deve inseri-lo no momento de criar uma nova conta no app.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                coachCode,
                style: const TextStyle(
                  color: Color(0xFF06B6D4),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: coachCode));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Código copiado! Envie pelo WhatsApp."),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, color: Colors.black),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                label: const Text(
                  "COPIAR CÓDIGO DA ASSESSORIA",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
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
}

class _OrgMetric extends StatelessWidget {
  final String label, value;
  const _OrgMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
