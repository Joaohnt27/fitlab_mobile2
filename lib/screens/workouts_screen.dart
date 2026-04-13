import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/subscription_screen.dart';
import 'all_challenges_screen.dart';
import '../widgets/challenge_card.dart';
import '../widgets/lab_goals_card.dart';
import '../widgets/fitlab_ai_card.dart';
import '../widgets/ai_training_result_card.dart';
import '../widgets/coach_dashboard.dart';
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
    context.read<UserProvider>().salvarExperimentoUsuario(
      context,
      volume,
      frequencia,
    );
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
      "A IA está sintetizando seu treino. Disponível por 24 horas.",
      isAI: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch monitora mudanças no plano ou role
    final userProvider = context.watch<UserProvider>();
    final usuario = userProvider.usuarioLogado;

    final bool isTreinador = usuario?.role == 'Treinador';
    final bool isPremium =
        usuario?.plano != null &&
        usuario!.plano != 'Free' &&
        usuario.plano != '';

    final activeChallenges = ChallengesData.allChallenges
        .where((c) => c["isActive"] == true)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(usuario?.streak ?? 0),
          const SliverToBoxAdapter(child: _PageIntroText()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PAINEL DINÂMICO (TREINADOR VS ATLETA) ---
                  if (isTreinador) ...[
                    const CoachDashboard(),
                  ] else ...[
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
                        : FitLabAICard(onGenerate: _aoGerarTreinoIA),
                    const SizedBox(height: 32),
                    const _SectionHeader(title: "Configurar Experimento"),
                    const SizedBox(height: 16),
                    LabGoalsCard(onIniciar: _iniciarExperimento),
                  ],

                  // --- SEÇÃO DE DESAFIOS ---
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

                  // --- SEÇÃO PLANO SEMANAL (BLOQUEIO PREMIUM) ---
                  if (!isTreinador) ...[
                    const SizedBox(height: 32),
                    const _SectionHeader(title: "Plano Semanal"),
                    const SizedBox(height: 16),
                    _buildWeeklyPlanWithAccessControl(isPremium),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget de controle de acesso ao plano semanal
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
          _buildLockOverlay(),
        ],
      ),
    );
  }

  // Overlay de Cadeado para usuários Free
  Widget _buildLockOverlay() {
    return Column(
      children: [
        const Icon(Icons.lock_outline, color: Color(0xFF06B6D4), size: 28),
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
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
          ),
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
    );
  }

  Widget _buildSliverAppBar(int streak) {
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
      actions: [_StreakIndicator(streak: streak)],
    );
  }

  void _showCustomDialog(String title, String content, {bool isAI = false}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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

// --- SUB-WIDGETS (SÃO PRIVADOS OU PODEM IR PARA OUTROS ARQUIVOS) ---

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
  final int streak;
  const _StreakIndicator({required this.streak});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Center(
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
        style: TextStyle(color: Colors.white70, fontSize: 14),
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
      height: 120,
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
