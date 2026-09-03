import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:fitlab_mobile2/providers/user_provider.dart';
import 'package:fitlab_mobile2/config/api_constants.dart';
import 'package:fitlab_mobile2/screens/chat_central_screen.dart';
import 'package:fitlab_mobile2/screens/coach_ai_training_screen.dart';
import 'package:fitlab_mobile2/screens/coach_team_management_screen.dart';
import 'package:fitlab_mobile2/screens/create_challenge_screen.dart';
import 'package:fitlab_mobile2/screens/prescribe_training_screen.dart';
import 'package:fitlab_mobile2/screens/student_management_screen.dart';
import 'package:fitlab_mobile2/screens/students_ranking_screen.dart';

class CoachDashboard extends StatefulWidget {
  const CoachDashboard({super.key});

  @override
  State<CoachDashboard> createState() => _CoachDashboardState();
}

class _CoachDashboardState extends State<CoachDashboard> {
  double _ratingCoach = 5.0;
  int _alunosAtivos = 0; // 👇 NOVA VARIÁVEL PARA O CARD
  List<dynamic> _solicitacoesPendentes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosDashboard();
  }

  // 👇 BUSCA PENDENTES E A QUANTIDADE DE ALUNOS REAIS 👇
  Future<void> _carregarDadosDashboard() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idCoach = userProvider.usuarioLogado?.id;
    if (idCoach == null) return;

    setState(() => _isLoading = true);

    try {
      final urlPendentes = Uri.parse(
        '${ApiConstants.baseUrl}/mentorias/treinador/$idCoach/pendentes',
      );
      final urlContagem = Uri.parse(
        '${ApiConstants.baseUrl}/mentorias/treinador/$idCoach/alunos/count',
      );

      final responsePendentes = await http.get(urlPendentes);
      final responseContagem = await http.get(urlContagem);

      setState(() {
        if (responsePendentes.statusCode == 200) {
          _solicitacoesPendentes = json.decode(
            utf8.decode(responsePendentes.bodyBytes),
          );
        }

        if (responseContagem.statusCode == 200) {
          // Atualiza a quantidade real de alunos que veio do Java!
          _alunosAtivos = int.tryParse(responseContagem.body) ?? 0;
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar dashboard do coach: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _responderSolicitacao(int idMentoria, bool aceitar) async {
    final url = aceitar
        ? Uri.parse('${ApiConstants.baseUrl}/mentorias/$idMentoria/aceitar')
        : Uri.parse('${ApiConstants.baseUrl}/mentorias/$idMentoria/recusar');

    try {
      final response = aceitar ? await http.put(url) : await http.delete(url);

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                aceitar
                    ? "Atleta adicionado à sua equipe!"
                    : "Solicitação recusada.",
              ),
              backgroundColor: aceitar
                  ? const Color(0xFF06B6D4)
                  : Colors.redAccent,
            ),
          );
        }

        if (context.mounted) {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          await userProvider.recarregarUsuario();
        }

        _carregarDadosDashboard(); // Recarrega a lista e a quantidade de alunos
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao processar solicitação: ${response.body}"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Erro na requisição: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final planoObj = userProvider.usuarioLogado?.plano;
    final String nomePlanoAtual = planoObj?['nome'] ?? "Coach Start";
    final bool canUseIA =
        nomePlanoAtual == 'Coach Pro' || nomePlanoAtual == 'Coach Elite';
    final bool isElite = nomePlanoAtual == 'Coach Elite';

    // 👇 Resgata o status do usuário (Treinador) atual 👇
    final String statusCref =
        userProvider.usuarioLogado?.statusCref ?? "SEM_CREF";

    final String limiteAlunos = nomePlanoAtual == 'Coach Start'
        ? "20"
        : (nomePlanoAtual == 'Coach Pro' ? "60" : "∞");

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
      );
    }

    // 👇 ADICIONADO REFRESH INDICATOR E SCROLL VIEW 👇
    return RefreshIndicator(
      color: const Color(0xFF06B6D4),
      backgroundColor: const Color(0xFF1A1A1A),
      onRefresh: () async {
        // Recarrega o perfil do treinador e os dados do dashboard ao puxar a tela
        await Provider.of<UserProvider>(
          context,
          listen: false,
        ).recarregarUsuario();
        await _carregarDadosDashboard();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👇 PLANO, BADGE DO CREF E RATING AQUI 👇
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildCoachPlanBadge(nomePlanoAtual.toUpperCase()),
                    const SizedBox(width: 8),
                    _buildCrefBadge(statusCref), // Utiliza a nova função visual
                  ],
                ),
                _buildRatingBadge(_ratingCoach),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _StatMiniCard(
                  label: "ALUNOS ATIVOS",
                  // 👇 AGORA EXIBE A VARIÁVEL REAL QUE VEIO DO BANCO 👇
                  value: "$_alunosAtivos/$limiteAlunos",
                  color: Colors.greenAccent,
                  icon: Icons.people_alt_rounded,
                ),
                const SizedBox(width: 12),
                _StatMiniCard(
                  label: "SALDO A RECEBER",
                  value:
                      "R\$ ${(userProvider.usuarioLogado?.saldoFinanceiro ?? 0.0).toStringAsFixed(2).replaceAll('.', ',')}",
                  color: Colors.amber,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (_solicitacoesPendentes.isNotEmpty) ...[
              const _DashboardSectionHeader(
                title: "NOVOS ATLETAS ELITE",
                subtitle: "Solicitações de mentoria pendentes",
              ),
              const SizedBox(height: 12),
              ..._solicitacoesPendentes.map(
                (aluno) => _buildMentorshipRequestCard(aluno),
              ),
              const SizedBox(height: 24),
            ],

            const Text(
              "AÇÕES DE LABORATÓRIO",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            _buildQuickActionsGrid(context, canUseIA, isElite),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DashboardSectionHeader(
                  title: isElite
                      ? "RANKING DE EQUIPES"
                      : "RANKING DE PRODUTIVIDADE",
                  subtitle: "Líderes de volume e frequência",
                ),
                _buildBadgeCounter("MÊS ATUAL", Icons.calendar_today_rounded),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.02)),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.white24,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Nenhum aluno cadastrado para ranquear",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentsRankingScreen(),
                    ),
                  );
                },
                child: const Text(
                  "VER RANKING COMPLETO",
                  style: TextStyle(
                    color: Color(0xFF06B6D4),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const _DashboardSectionHeader(
              title: "MEUS DESAFIOS ATIVOS",
              subtitle: "Gestão de engajamento",
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.02)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.flag_outlined, color: Colors.white24, size: 32),
                  SizedBox(height: 12),
                  Text(
                    "Nenhum desafio ativo no momento",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildCoachPlanBadge(String planName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF06B6D4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: Color(0xFF06B6D4),
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            planName,
            style: const TextStyle(
              color: Color(0xFF06B6D4),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 👇 Mapeia a string do status para o selo correspondente 👇
  Widget _buildCrefBadge(String status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case 'APROVADO':
        color = const Color(0xFF06B6D4);
        icon = Icons.verified;
        text = "CREF Verificado";
        break;
      case 'EM_AVALIACAO':
      case 'ENVIADO_AVALIACAO':
        color = Colors.amber;
        icon = Icons.pending_actions;
        text = "CREF em Análise";
        break;
      case 'RECUSADO':
        color = Colors.redAccent;
        icon = Icons.gpp_bad;
        text = "CREF Recusado";
        break;
      case 'SEM_CREF':
      default:
        color = Colors.redAccent;
        icon = Icons.warning_amber_rounded;
        text = "Atua sem CREF";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorshipRequestCard(Map<String, dynamic> aluno) {
    final int idVinculo = aluno['id'] ?? aluno['idMentoria'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white10,
            child: Text(
              aluno['avatar'] ?? "🏃‍♂️",
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aluno['nome'] ?? "Atleta Elite",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  aluno['objetivo'] != null
                      ? "Objetivo: ${aluno['objetivo']}"
                      : "Solicitação de mentoria",
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white38),
            onPressed: () => _responderSolicitacao(idVinculo, false),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF06B6D4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.check, color: Colors.black, size: 20),
              onPressed: () => _responderSolicitacao(idVinculo, true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(
    BuildContext context,
    bool canUseIA,
    bool isElite,
  ) {
    return GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: [
        _buildActionCard(Icons.groups_rounded, "Alunos e Turmas", () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentManagementScreen(),
            ),
          );
        }),
        _buildActionCard(Icons.fitness_center_rounded, "Prescrever Treino", () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PrescribeTrainingScreen(),
            ),
          );
        }),
        _buildActionCard(Icons.emoji_events_rounded, "Criar Desafio", () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateChallengeScreen(),
            ),
          );
        }),
        _buildActionCard(Icons.forum_rounded, "Central de Chat", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatCentralScreen()),
          );
        }),
        _buildActionCard(
          Icons.psychology_rounded,
          "IA de Treino",
          canUseIA
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CoachAITrainingScreen(),
                    ),
                  );
                }
              : null,
          isLocked: !canUseIA,
        ),
        if (isElite)
          _buildActionCard(
            Icons.manage_accounts_rounded,
            "Gestão de Equipe",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CoachTeamManagementScreen(),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String label,
    VoidCallback? onTap, {
    bool isLocked = false,
  }) {
    return Opacity(
      opacity: isLocked ? 0.4 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLocked ? Colors.white10 : Colors.white.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLocked ? Colors.grey : const Color(0xFF06B6D4),
                size: 18,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isLocked)
                const Icon(Icons.lock_outline, size: 12, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCounter(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF06B6D4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF06B6D4), size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF06B6D4),
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.02)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color.withOpacity(0.5), size: 16),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _DashboardSectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF06B6D4),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
}
