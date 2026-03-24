import 'package:fitlab_mobile2/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/pace_calculator_card.dart';
import '../widgets/challenge_card.dart';
import '../widgets/lab_goals_card.dart';
import 'all_challenges_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final List<Map<String, dynamic>> _allChallenges = [
    {
      "icon": "⚔️",
      "theme": "STAR WARS",
      "title": "O Caminho do Jedi",
      "desc": "Complete 42 km em 7 dias",
      "progress": 28.5,
      "total": 42.0,
      "reward": "Badge Mestre Jedi",
      "difficulty": "HARD",
    },
    {
      "icon": "🦸",
      "theme": "MARVEL",
      "title": "Protocolo Vingador",
      "desc": "Corra 5 dias consecutivos",
      "progress": 3.0,
      "total": 5.0,
      "reward": "Badge Vingador",
      "difficulty": "MEDIUM",
    },
    {
      "icon": "🪄",
      "theme": "HARRY POTTER",
      "title": "Copa Tribruxo",
      "desc": "Conquiste 10 territórios",
      "progress": 6.0,
      "total": 10.0,
      "reward": "Badge Campeão",
      "difficulty": "MEDIUM",
    },
  ];

  final _distanciaController = TextEditingController();
  final _tempoController = TextEditingController();
  String _resultadoPace = "0:00";

  void _iniciarExperimento(String volume, String frequencia) {
    debugPrint("Iniciando experimento: $volume km, $frequencia vezes/semana");
    Provider.of<UserProvider>(
      context,
      listen: false,
    ).salvarExperimentoUsuario(context, volume, frequencia);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.science, color: Color(0xFF06B6D4), size: 60),
                const SizedBox(height: 20),
                const Text(
                  "FÓRMULA PRONTA!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Seu experimento de $volume configurado com sucesso e já está rodando no seu Feed.",
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
        );
      },
    );
  }

  // Função para calcular o pace
  void _calcularPace() {
    double? distancia = double.tryParse(_distanciaController.text);
    double? tempoMinutos = double.tryParse(_tempoController.text);

    if (distancia != null && tempoMinutos != null && distancia > 0) {
      double paceDecimal = tempoMinutos / distancia;
      int minutos = paceDecimal.toInt();
      int segundos = ((paceDecimal - minutos) * 60).round();

      setState(() {
        _resultadoPace = "$minutos:${segundos.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A1A),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              collapseMode: CollapseMode.parallax,
              titlePadding: const EdgeInsets.only(bottom: 16),
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
                child: const Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.science_outlined,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Tooltip(
                  message: "Medidor de sequência",
                  triggerMode: TooltipTriggerMode.tap,
                  child: Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final streak = userProvider.usuarioLogado?.streak ?? 0;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: streak > 0
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: streak > 0
                                  ? Colors.orange
                                  : Colors.white38,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "$streak",
                              style: TextStyle(
                                color: streak > 0
                                    ? Colors.white
                                    : Colors.white38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 20, left: 24, right: 24),
              child: Text(
                "Seu centro de treinamento e desafios",
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Calculadora de Pace"),
                  const SizedBox(height: 16),

                  PaceCalculatorCard(
                    distController: _distanciaController,
                    tempoController: _tempoController,
                    resultado: _resultadoPace,
                    onCalcular: _calcularPace,
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader("Configurar Experimento"),
                  const SizedBox(height: 16),

                  // AGORA PASSAMOS A FUNÇÃO PARA O WIDGET
                  LabGoalsCard(
                    onIniciar: (volume, frequencia) {
                      _iniciarExperimento(volume, frequencia);
                    },
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    "Desafios Ativos",
                    onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AllChallengesScreen(challenges: _allChallenges),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  ..._allChallenges
                      .take(3)
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ChallengeCard(challenge: c),
                        ),
                      ),

                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    "Plano Semanal",
                    subtitle: "Coach Ricardo Silva",
                  ),
                  const SizedBox(height: 16),
                  _buildTrainingPlanPlaceholder(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    String? subtitle,
    VoidCallback? onViewAll,
  }) {
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
                subtitle,
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

  Widget _buildTrainingPlanPlaceholder() {
    return Container(
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
