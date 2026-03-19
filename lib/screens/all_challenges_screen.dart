import 'package:flutter/material.dart';

class AllChallengesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> challenges;

  const AllChallengesScreen({super.key, required this.challenges});

  // Função para mostrar a insígnia
  void _showRewardDetails(
    BuildContext context,
    Map<String, dynamic> challenge,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            challenge['reward'].toString().toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF06B6D4),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "🏆",
                style: TextStyle(fontSize: 60),
              ), // Ícone da Insígnia
              const SizedBox(height: 16),
              Text(
                "Ao completar o desafio '${challenge['title']}', você desbloqueará esta insígnia exclusiva no seu perfil!",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "FECHAR",
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "TODOS OS DESAFIOS",
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final c = challenges[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            // Envolvendo o tile com clique
            child: GestureDetector(
              onTap: () => _showRewardDetails(context, c),
              child: _buildPremiumTile(c),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumTile(Map<String, dynamic> c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Text(c['icon'], style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c['theme'],
                  style: const TextStyle(
                    color: Color(0xFF06B6D4),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  c['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  c['desc'],
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: c['progress'] / c['total'],
                  backgroundColor: Colors.white10,
                  color: const Color(0xFF06B6D4),
                  minHeight: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 14),
        ],
      ),
    );
  }
}
