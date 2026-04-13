import 'package:flutter/material.dart';

class PrescriptionHistoryScreen extends StatefulWidget {
  const PrescriptionHistoryScreen({super.key});

  @override
  State<PrescriptionHistoryScreen> createState() =>
      _PrescriptionHistoryScreenState();
}

class _PrescriptionHistoryScreenState extends State<PrescriptionHistoryScreen> {
  // Filtro atual: 0 = Todos, 1 = Individual, 2 = Turma
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "HISTÓRICO DE FÓRMULAS",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          const SizedBox(height: 16),
          Expanded(child: _buildHistoryList()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _filterChip(0, "TODOS"),
          _filterChip(1, "INDIVIDUAL"),
          _filterChip(2, "TURMAS"),
        ],
      ),
    );
  }

  Widget _filterChip(int index, String label) {
    bool isSelected = _filterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        onSelected: (val) => setState(() => _filterIndex = index),
        selectedColor: const Color(0xFF06B6D4),
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.white10,
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    // Dados fakes para o TCC
    final history = [
      {
        "title": "Longão Progressivo",
        "target": "Turma Elite Sprint",
        "date": "Hoje, 08:30",
        "type": "TURMA",
      },
      {
        "title": "Intervalado 400m",
        "target": "João Henrique",
        "date": "Ontem, 17:00",
        "type": "INDIVIDUAL",
      },
      {
        "title": "Recuperativo Z1",
        "target": "Maria Cobaia",
        "date": "10 Abr 2026",
        "type": "INDIVIDUAL",
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              item['title']!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  "Para: ${item['target']}",
                  style: const TextStyle(
                    color: Color(0xFF06B6D4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.white24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['date']!,
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item['type']!,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
