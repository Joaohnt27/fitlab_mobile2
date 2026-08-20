import 'package:flutter/material.dart';

class RunHistoryScreen extends StatelessWidget {
  const RunHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dados simulados para o Front-end
    final List<Map<String, dynamic>> corridas = [
      {
        "data": "18 Ago 2026",
        "distancia": "5.2 km",
        "pace": "5'30\"",
        "tempo": "28:36",
      },
      {
        "data": "15 Ago 2026",
        "distancia": "10.0 km",
        "pace": "5'45\"",
        "tempo": "57:30",
      },
      {
        "data": "10 Ago 2026",
        "distancia": "3.0 km",
        "pace": "5'15\"",
        "tempo": "15:45",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "HISTÓRICO DE CORRIDAS",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: corridas.length,
        itemBuilder: (context, index) {
          final corrida = corridas[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      corrida["data"],
                      style: const TextStyle(
                        color: Color(0xFF06B6D4),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      corrida["distancia"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatRow(Icons.timer_outlined, corrida["tempo"]),
                    const SizedBox(height: 8),
                    _buildStatRow(Icons.speed, "${corrida["pace"]} /km"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
