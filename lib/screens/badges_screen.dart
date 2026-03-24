import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../widgets/badge_item.dart';

class BadgesScreen extends StatefulWidget {
  final List<BadgeModel> allBadges;
  const BadgesScreen({super.key, required this.allBadges});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  String selectedTheme = 'Todos';
  String selectedRarity = 'Todas';

  @override
  Widget build(BuildContext context) {
    // Lógica de Filtragem
    final filteredBadges = widget.allBadges.where((badge) {
      bool matchesTheme =
          selectedTheme == 'Todos' || badge.theme == selectedTheme;
      bool matchesRarity =
          selectedRarity == 'Todas' ||
          badge.rarity.toString().split('.').last ==
              selectedRarity.toLowerCase();
      return matchesTheme && matchesRarity;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "MINHAS CONQUISTAS",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterBar(), // Barra de filtros
          Expanded(
            child: filteredBadges.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhuma conquista encontrada",
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 por linha na tela
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 15,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: filteredBadges.length,
                    itemBuilder: (context, index) {
                      return BadgeItem(
                        badge: filteredBadges[index],
                        context: context,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _filterChip(
            "Temas",
            ['Todos', 'Marvel', 'Star Wars', 'Esporte'],
            selectedTheme,
            (val) {
              setState(() => selectedTheme = val);
            },
          ),
          const SizedBox(width: 10),
          _filterChip(
            "Raridade",
            ['Todas', 'Common', 'Rare', 'Epic', 'Legendary'],
            selectedRarity,
            (val) {
              setState(() => selectedRarity = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    String label,
    List<String> options,
    String currentVal,
    Function(String) onSelect,
  ) {
    return PopupMenuButton<String>(
      onSelected: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Text(
              currentVal,
              style: const TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => options
          .map((opt) => PopupMenuItem(value: opt, child: Text(opt)))
          .toList(),
    );
  }
}
