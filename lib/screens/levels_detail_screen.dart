import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../providers/user_provider.dart';

class LevelsDetailScreen extends StatelessWidget {
  const LevelsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todosNiveis = AppData.levels;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "RANKING DO LABORATÓRIO",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final xpAtual = userProvider.usuarioLogado?.xp ?? 0;

          final nivelUsuarioAtual = AppData.getNivelByXP(xpAtual);
          final int lvAtivo = nivelUsuarioAtual['lv'];

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: todosNiveis.length,
            itemBuilder: (context, index) {
              final nivel = todosNiveis[index];
              final int lvItem = nivel['lv'];

              bool ehAtual = lvItem == lvAtivo;
              bool bloqueado = lvItem > lvAtivo;

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
                          "${nivel['min']} - ${nivel['max']} XP",
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (ehAtual)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF06B6D4),
                            size: 16,
                          )
                        else if (bloqueado)
                          const Icon(
                            Icons.lock_outline,
                            color: Colors.white10,
                            size: 16,
                          )
                        else
                          const Icon(
                            Icons.verified,
                            color: Colors.white24,
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
