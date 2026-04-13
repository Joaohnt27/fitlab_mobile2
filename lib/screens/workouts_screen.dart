import 'dart:ui';
import 'package:fitlab_mobile2/providers/user_provider.dart';
import 'package:fitlab_mobile2/screens/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/challenge_card.dart';
import '../widgets/lab_goals_card.dart';
import '../widgets/fitlab_ai_card.dart';
import '../widgets/ai_training_result_card.dart';
import 'all_challenges_screen.dart';
import '../data/challenges_data.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  bool _hasGeneratedAIWorkout = false;
  Map<String, dynamic> aiRequestData = {"goal": "", "timeframe": ""};

  void _iniciarExperimento(String volume, String frequencia) {
    Provider.of<UserProvider>(
      context,
      listen: false,
    ).salvarExperimentoUsuario(context, volume, frequencia);
    _showCustomDialog(
      "FÓRMULA PRONTA!",
      "Seu experimento de $volume configurado.",
    );
  }

  void _aoGerarTreinoIA(Map<String, dynamic> data) {
    setState(() {
      aiRequestData = data;
      _hasGeneratedAIWorkout = true;
    });

    _showCustomDialog(
      "PROCESSANDO DADOS...",
      "A IA está sintetizando seu treino para '${data['goal']}'. Este treino ficará disponível no Lab por apenas 24 horas.",
      isAI: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isTreinador = userProvider.usuarioLogado?.role == 'Treinador';
    final bool isPremium =
        userProvider.usuarioLogado?.plano == 'Pro' ||
        userProvider.usuarioLogado?.plano == 'Elite';

    final activeChallenges = ChallengesData.allChallenges
        .where((c) => c["isActive"] == true)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          const SliverToBoxAdapter(child: _PageIntroText()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- LÓGICA DE ALTERNÂNCIA DE PAINEL ---
                  if (isTreinador) ...[
                    const _SectionHeader(
                      title: "Central do Treinador",
                      subtitle: "Monitoramento de performance",
                    ),
                    const SizedBox(height: 16),
                    _buildCoachDashboard(), // Chama o painel novo
                  ] else ...[
                    // --- CONTEÚDO ORIGINAL DO ATLETA ---
                    const _SectionHeader(
                      title: "Cérebro FitLab",
                      subtitle: "Inteligência Artificial",
                    ),
                    const SizedBox(height: 16),
                    _hasGeneratedAIWorkout
                        ? AITrainingResultCard(
                            data: aiRequestData,
                            onStart: () => debugPrint("Iniciando GPS..."),
                          )
                        : FitLabAICard(
                            onGenerate: (data) => _aoGerarTreinoIA(data),
                          ),
                    const SizedBox(height: 32),
                    const SizedBox(height: 32),
                    const _SectionHeader(title: "Configurar Experimento"),
                    const SizedBox(height: 16),
                    LabGoalsCard(onIniciar: _iniciarExperimento),
                  ],

                  // Desafios e Plano Semanal (Comuns a ambos ou filtrados)
                  const SizedBox(height: 32),
                  _SectionHeader(
                    title: "Desafios Ativos",
                    onViewAll: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllChallengesScreen(
                          challenges: ChallengesData.allChallenges,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...activeChallenges
                      .take(3)
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ChallengeCard(challenge: c),
                        ),
                      ),
                  const SizedBox(height: 32),
                  const _SectionHeader(title: "Plano Semanal"),
                  const SizedBox(height: 16),
                  _buildWeeklyPlanWithAccessControl(isPremium),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlanWithAccessControl(bool isPremium) {
    if (isPremium) return const _TrainingPlanPlaceholder();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.1,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const _TrainingPlanPlaceholder(),
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF06B6D4).withOpacity(0.5),
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF06B6D4),
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "ACESSO RESTRITO",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
              const Text(
                "Disponível apenas para membros Pro e Elite",
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionScreen(),
                    ),
                  );
                },
                child: const Text(
                  "FAZER UPGRADE",
                  style: TextStyle(
                    color: Color(0xFF06B6D4),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A1A),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          "LABORATÓRIO",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1D4ED8), Color(0xFF0D0D0D)],
            ),
          ),
          child: const Center(
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.science_outlined,
                size: 120,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      actions: [const _StreakIndicator()],
    );
  }

  void _showCustomDialog(String title, String content, {bool isAI = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAI ? Icons.psychology : Icons.science,
                color: const Color(0xFF06B6D4),
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "VAMOS NESSA!",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;
  const _SectionHeader({required this.title, this.subtitle, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
          ],
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text(
              "VER TODOS",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class _StreakIndicator extends StatelessWidget {
  const _StreakIndicator();
  @override
  Widget build(BuildContext context) {
    final streak = context.watch<UserProvider>().usuarioLogado?.streak ?? 0;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: streak > 0 ? Colors.orange.withOpacity(0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              color: streak > 0 ? Colors.orange : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              "$streak",
              style: TextStyle(
                color: streak > 0 ? Colors.white : Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIntroText extends StatelessWidget {
  const _PageIntroText();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 20, left: 24, right: 24),
      child: Text(
        "Seu centro de treinamento e desafios",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _TrainingPlanPlaceholder extends StatelessWidget {
  const _TrainingPlanPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const Center(
        child: Text(
          "Plano Semanal Carregado",
          style: TextStyle(color: Colors.white38),
        ),
      ),
    );
  }
}

Widget _buildCoachDashboard() {
  return Column(
    children: [
      Row(
        children: [
          _buildStatMiniCard("ALUNOS ATIVOS", "12", Colors.green),
          const SizedBox(width: 12),
          _buildStatMiniCard("ALERTAS HOJE", "3", Colors.orange),
        ],
      ),
      const SizedBox(height: 32),
      const _SectionHeader(
        title: "Gestão de Cobaias",
        subtitle: "Progresso dos seus alunos",
      ),
      const SizedBox(height: 16),
      // Aqui você usaria o CoachStudentCard que criamos antes
      _tempStudentTile("Arthur Vital", "Treino Pendente", 5),
      _tempStudentTile("Maria Silva", "Concluído", 15),
      const SizedBox(height: 24),
      _buildActionBtn(Icons.add_chart, "LANÇAR NOVO EXPERIMENTO"),
    ],
  );
}

Widget _buildStatMiniCard(String label, String value, Color color) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _tempStudentTile(String name, String status, int streak) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.03),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: const Color(0xFF06B6D4).withOpacity(0.2),
          child: Text(
            name[0],
            style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 12),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          status,
          style: TextStyle(
            color: status == "Concluído" ? Colors.green : Colors.orange,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

Widget _buildActionBtn(IconData icon, String label) {
  return ElevatedButton.icon(
    onPressed: () {},
    icon: Icon(icon, size: 18),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF06B6D4),
      foregroundColor: Colors.black,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
