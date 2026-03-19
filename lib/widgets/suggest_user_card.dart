import 'package:flutter/material.dart';

class SuggestUserCard extends StatelessWidget {
  final String nome;

  const SuggestUserCard({super.key, required this.nome});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
              ),
            ),
            child: const CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFF0D0D0D),
              child: Icon(Icons.person, color: Colors.white24, size: 30),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nome,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Botão Seguir
          SizedBox(
            height: 32,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Lógica de seguir futura
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4).withOpacity(0.1),
                foregroundColor: const Color(0xFF06B6D4),
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "SEGUIR",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
