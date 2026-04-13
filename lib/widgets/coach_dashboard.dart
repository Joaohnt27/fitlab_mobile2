import 'package:fitlab_mobile2/providers/user_provider.dart';
import 'package:fitlab_mobile2/screens/chat_central_screen.dart';
import 'package:fitlab_mobile2/screens/coach_ai_training_screen.dart';
import 'package:fitlab_mobile2/screens/coach_team_management_screen.dart';
import 'package:fitlab_mobile2/screens/create_challenge_screen.dart';
import 'package:fitlab_mobile2/screens/prescribe_training_screen.dart';
import 'package:fitlab_mobile2/screens/student_management_screen.dart';
import 'package:fitlab_mobile2/screens/students_ranking_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CoachDashboard extends StatelessWidget {
  const CoachDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final plano = userProvider.usuarioLogado?.plano ?? "Coach Start";
    final bool canUseIA = plano == 'Coach Pro' || plano == 'Coach Elite';
    final bool isElite = plano == 'Coach Elite';
    final String limiteAlunos = plano == 'Coach Start'
        ? "20"
        : (plano == 'Coach Pro' ? "60" : "∞");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StatMiniCard(
              label: "ALUNOS ATIVOS",
              value: "12/$limiteAlunos",
              color: Colors.greenAccent,
              icon: Icons.people_alt_rounded,
            ),
            const SizedBox(width: 12),
            const _StatMiniCard(
              label: "MÉDIA EVOLUÇÃO",
              value: "+12%",
              color: Color(0xFF06B6D4),
              icon: Icons.trending_up_rounded,
            ),
          ],
        ),

        const SizedBox(height: 16),
        _buildCoachPlanBadge(plano.toUpperCase()),

        const SizedBox(height: 24),

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

        _buildRankingStudentTile(
          position: 1,
          name: "Arthur Vital",
          km: 154.2,
          totalWorkouts: 22,
          accentColor: Colors.greenAccent,
        ),
        _buildRankingStudentTile(
          position: 2,
          name: "Maria Silva",
          km: 120.5,
          totalWorkouts: 18,
          accentColor: const Color(0xFF06B6D4),
        ),
        _buildRankingStudentTile(
          position: 3,
          name: "João Henrique",
          km: 98.0,
          totalWorkouts: 15,
          accentColor: Colors.orangeAccent,
        ),
        _buildRankingStudentTile(
          position: 4,
          name: "Lucas Rocha",
          km: 85.4,
          totalWorkouts: 12,
          accentColor: Colors.purpleAccent,
        ),
        _buildRankingStudentTile(
          position: 5,
          name: "Beatriz Lima",
          km: 77.2,
          totalWorkouts: 10,
          accentColor: Colors.pinkAccent,
        ),

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

        _buildCoachChallengeCard(
          context,
          title: "Maratona de Outono",
          participants: 28,
          timeLeft: "4 dias",
          onEnd: () =>
              _confirmarEncerramentoDesafio(context, "Maratona de Outono"),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

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
        _buildActionCard(Icons.group_add_rounded, "Alunos e Turmas", () {
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
        // IA de Treino (Requisito Coach Pro/Elite)
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
              : null, // Se não puder usar, o botão fica nulo (desabilitado)
          isLocked: !canUseIA,
        ),
        // Gestão de Equipe (Requisito Coach Elite)
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

  Widget _buildRankingStudentTile({
    required int position,
    required String name,
    required double km,
    required int totalWorkouts,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 25,
            child: Text(
              "$position",
              style: TextStyle(
                color: position <= 3 ? const Color(0xFF06B6D4) : Colors.white24,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: accentColor.withOpacity(0.1),
            child: Text(
              name[0],
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "$totalWorkouts treinos realizados",
                  style: const TextStyle(color: Colors.white30, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${km.toStringAsFixed(1)} km",
                style: const TextStyle(
                  color: Color(0xFF06B6D4),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const Text(
                "TOTAL",
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
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

  Widget _buildCoachChallengeCard(
    BuildContext context, {
    required String title,
    required int participants,
    required String timeLeft,
    required VoidCallback onEnd,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      color: Color(0xFF06B6D4),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$participants",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.timer_outlined,
                      color: Colors.orangeAccent,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeLeft,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onEnd,
            child: const Text(
              "ENCERRAR",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarEncerramentoDesafio(BuildContext context, String nome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "ENCERRAR EXPERIMENTO?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Deseja finalizar o desafio '$nome'? O ranking será congelado.",
          style: const TextStyle(color: Colors.white70, fontSize: 12),
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
              "ENCERRAR",
              style: TextStyle(color: Colors.redAccent),
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
