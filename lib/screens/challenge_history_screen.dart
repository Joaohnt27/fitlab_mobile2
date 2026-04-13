import 'package:flutter/material.dart';

class ChallengeHistoryScreen extends StatefulWidget {
  const ChallengeHistoryScreen({super.key});

  @override
  State<ChallengeHistoryScreen> createState() => _ChallengeHistoryScreenState();
}

class _ChallengeHistoryScreenState extends State<ChallengeHistoryScreen> {
  int _activeFilter = 0; // 0: Todos, 1: Ativos, 2: Finalizados

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
          "LOG DE EXPERIMENTOS",
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
          _buildStatusFilters(),
          const SizedBox(height: 24),
          Expanded(child: _buildChallengeList()),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _filterChip(0, "TODOS"),
          _filterChip(1, "EM CURSO"),
          _filterChip(2, "CONCLUÍDOS"),
        ],
      ),
    );
  }

  Widget _filterChip(int index, String label) {
    bool isSelected = _activeFilter == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        onSelected: (val) => setState(() => _activeFilter = index),
        selectedColor: const Color(0xFF06B6D4),
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.white10,
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildChallengeList() {
    final challenges = [
      {
        "title": "Sprint de Inverno 50k",
        "target": "Turma Elite",
        "status": "Ativo",
        "type": 1,
        "participants": 42,
      },
      {
        "title": "Desafio de Elevação",
        "target": "Todos os Alunos",
        "status": "Concluído",
        "type": 2,
        "participants": 128,
      },
      {
        "title": "Consistência Lab Z2",
        "target": "Iniciantes",
        "status": "Ativo",
        "type": 1,
        "participants": 15,
      },
    ];

    final filtered = _activeFilter == 0
        ? challenges
        : challenges.where((c) => c['type'] == _activeFilter).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        bool isActive = item['type'] == 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF06B6D4).withOpacity(0.2)
                  : Colors.white.withOpacity(0.03),
            ),
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: isActive ? 0.6 : 1.0,
                    strokeWidth: 2,
                    color: isActive ? const Color(0xFF06B6D4) : Colors.white10,
                    backgroundColor: Colors.white.withOpacity(0.05),
                  ),
                  Icon(
                    isActive
                        ? Icons.bolt_rounded
                        : Icons.check_circle_outline_rounded,
                    color: isActive ? const Color(0xFF06B6D4) : Colors.white24,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item['target']} • ${item['participants']} Atletas",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.analytics_outlined,
                color: Colors.white10,
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
