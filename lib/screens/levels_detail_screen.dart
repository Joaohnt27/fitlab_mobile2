import 'package:flutter/material.dart';
import '../models/app_data.dart';

class LevelsDetailScreen extends StatelessWidget {
  const LevelsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de todos os níveis
    final List<Map<String, dynamic>> todosNiveis = [
      {
        "lv": 1,
        "nome": "Recruta do laboratório",
        "xp": "0 - 75 XP",
        "icon": "🧪",
      },
      {"lv": 2, "nome": "Voluntário Ativo", "xp": "75 - 115 XP", "icon": "🧬"},
      {
        "lv": 3,
        "nome": "Testador de Performance",
        "xp": "115 - 150 XP",
        "icon": "📊",
      },
      {
        "lv": 4,
        "nome": "Atleta em análise",
        "xp": "150 - 200 XP",
        "icon": "🏃",
      },
      {
        "lv": 5,
        "nome": "Protótipo atlético",
        "xp": "200 - 260 XP",
        "icon": "🦾",
      },
      {"lv": 6, "nome": "Modelo avançado", "xp": "260 - 320 XP", "icon": "⚡"},
      {
        "lv": 7,
        "nome": "Unidade de Alta Performance",
        "xp": "320 - 380 XP",
        "icon": "🛰️",
      },
      {"lv": 8, "nome": "Elite Experimental", "xp": "380+ XP", "icon": "🏆"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "RANKING DO LABORATÓRIO",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: AppData.userXP,
        builder: (context, xpAtual, child) {
          final nivelUsuario = AppData.nivelAtual['lv'];

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: todosNiveis.length,
            itemBuilder: (context, index) {
              final nivel = todosNiveis[index];
              bool ehAtual = nivel['lv'] == nivelUsuario;
              bool bloqueado = nivel['lv'] > nivelUsuario;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ehAtual
                      ? const Color(0xFF1D4ED8).withOpacity(0.1)
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ehAtual
                        ? const Color(0xFF06B6D4)
                        : Colors.white.withOpacity(0.05),
                    width: ehAtual ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Ícone com opacidade se estiver bloqueado
                    Opacity(
                      opacity: bloqueado ? 0.3 : 1.0,
                      child: Text(
                        nivel['icon'],
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "NÍVEL ${nivel['lv']}",
                            style: TextStyle(
                              color: ehAtual
                                  ? const Color(0xFF06B6D4)
                                  : Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            nivel['nome'],
                            style: TextStyle(
                              color: bloqueado ? Colors.white24 : Colors.white,
                              fontSize: 15,
                              fontWeight: ehAtual
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          nivel['xp'],
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                        if (ehAtual)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF06B6D4),
                            size: 16,
                          ),
                        if (bloqueado)
                          const Icon(
                            Icons.lock_outline,
                            color: Colors.white10,
                            size: 16,
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
