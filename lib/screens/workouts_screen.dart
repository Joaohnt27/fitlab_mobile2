import 'package:flutter/material.dart';

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
    {
      "icon": "⚡",
      "theme": "DC COMICS",
      "title": "Velocidade da Luz",
      "desc": "Corra 10km abaixo de 50min",
      "progress": 0.0,
      "total": 10.0,
      "reward": "Badge Flash",
      "difficulty": "HARD",
    },
  ];
  final _distanciaController = TextEditingController();
  final _tempoController = TextEditingController();
  String _resultadoPace = "0:00";

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("⚠️ Insira valores válidos para o cálculo."),
          backgroundColor: const Color(0xFF06B6D4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: "OK",
            textColor: const Color(0xFF1E1E1E),
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1D4ED8),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Laboratório',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Seu centro de treinamento e desafios',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1D4ED8), Color(0xFF0D1B2A)],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Calculadora de Pace"),
                  const SizedBox(height: 16),
                  _buildPaceCalculatorCard(),
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    "Desafios Ativos",
                    onViewAll: () {
                      // Navegação para nova interface de desafios
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
                  // Mapeia apenas os 3 primeiros desafios da lista
                  ..._allChallenges
                      .take(3)
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildChallengeCard(
                            icon: c['icon'],
                            theme: c['theme'],
                            title: c['title'],
                            desc: c['desc'],
                            progress: c['progress'],
                            total: c['total'],
                            reward: c['reward'],
                            difficulty: c['difficulty'],
                          ),
                        ),
                      ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    "Plano Semanal",
                    subtitle: "Coach Ricardo Silva",
                  ),
                  const SizedBox(height: 16),
                  _buildTrainingPlan(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaceCalculatorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInput("DISTÂNCIA (KM)", _distanciaController),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildInput("TEMPO (MIN)", _tempoController)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "RITMO ALVO",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    "$_resultadoPace",
                    style: const TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    "min/km",
                    style: TextStyle(color: Color(0xFF06B6D4), fontSize: 12),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _calcularPace,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF06B6D4).withOpacity(0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const Text(
                    "CALCULAR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF06B6D4),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF06B6D4)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard({
    required String icon,
    required String theme,
    required String title,
    required String desc,
    required double progress,
    required double total,
    required String reward,
    required String difficulty,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme,
                      style: const TextStyle(
                        color: Color(0xFF06B6D4),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDifficultyTag(difficulty),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress / total,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: const Color(0xFF06B6D4),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("🏆 ", style: TextStyle(fontSize: 14)),
                  Text(
                    reward,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              Text(
                '${progress.toStringAsFixed(1)} / $total km',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // tags de dificuldade
  Widget _buildDifficultyTag(String difficulty) {
    Color color = difficulty == "HARD" ? Colors.redAccent : Colors.orangeAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
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
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
          ],
        ),
        // botão "Ver Todos" 
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

  Widget _buildTrainingPlan() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.white.withOpacity(0.03), height: 1),
        itemBuilder: (context, index) {
          bool completed = index < 2;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Icon(
              completed
                  ? Icons.check_circle_rounded
                  : Icons.panorama_fish_eye_rounded,
              color: completed ? const Color(0xFF06B6D4) : Colors.white10,
            ),
            title: Text(
              index == 0 ? "Intervalado" : "Rodagem",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              "Foco em cadência",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            trailing: Text(
              index == 0 ? "6 km" : "4 km",
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
