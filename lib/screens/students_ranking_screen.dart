import 'package:flutter/material.dart';

class StudentsRankingScreen extends StatefulWidget {
  const StudentsRankingScreen({super.key});

  @override
  State<StudentsRankingScreen> createState() => _StudentsRankingScreenState();
}

class _StudentsRankingScreenState extends State<StudentsRankingScreen> {
  int _activeTimeFilter = 0; // 0: Mês, 1: Semana, 2: Geral

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "RANKING DE PERFORMANCE",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTimeFilters(),
          const SizedBox(height: 24),
          Expanded(child: _buildFullRankingList()),
        ],
      ),
    );
  }

  Widget _buildTimeFilters() {
    final filters = ["MÊS ATUAL", "ESTA SEMANA", "HISTÓRICO GERAL"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(filters.length, (index) {
          bool isSelected = _activeTimeFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              onSelected: (val) => setState(() => _activeTimeFilter = index),
              selectedColor: const Color(0xFF06B6D4),
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.white10,
              ),
              showCheckmark: false,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFullRankingList() {
    // Simulação de lista completa de alunos
    final allStudents = [
      {
        "name": "Arthur Vital",
        "km": 154.2,
        "workouts": 22,
        "color": Colors.greenAccent,
      },
      {
        "name": "Maria Silva",
        "km": 120.5,
        "workouts": 18,
        "color": const Color(0xFF06B6D4),
      },
      {
        "name": "João Henrique",
        "km": 98.0,
        "workouts": 15,
        "color": Colors.orangeAccent,
      },
      {
        "name": "Lucas Rocha",
        "km": 85.4,
        "workouts": 12,
        "color": Colors.purpleAccent,
      },
      {
        "name": "Beatriz Lima",
        "km": 77.2,
        "workouts": 10,
        "color": Colors.pinkAccent,
      },
      {
        "name": "Ricardo Gomes",
        "km": 60.1,
        "workouts": 8,
        "color": Colors.blueAccent,
      },
      {
        "name": "Fernanda Souza",
        "km": 45.3,
        "workouts": 6,
        "color": Colors.yellowAccent,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: allStudents.length,
      itemBuilder: (context, index) {
        final student = allStudents[index];
        final pos = index + 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: pos <= 3
                  ? const Color(0xFF06B6D4).withOpacity(0.1)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              _buildPositionBadge(pos),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 20,
                backgroundColor: (student['color'] as Color).withOpacity(0.1),
                child: Text(
                  student['name'].toString()[0],
                  style: TextStyle(
                    color: student['color'] as Color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${student['workouts']} treinos realizados",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${student['km']} km",
                style: const TextStyle(
                  color: Color(0xFF06B6D4),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPositionBadge(int pos) {
    if (pos <= 3) {
      return Icon(
        Icons.workspace_premium_rounded,
        color: pos == 1
            ? Colors.amber
            : (pos == 2 ? Colors.grey[400] : Colors.brown[300]),
        size: 24,
      );
    }
    return SizedBox(
      width: 24,
      child: Text(
        "$pos",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
