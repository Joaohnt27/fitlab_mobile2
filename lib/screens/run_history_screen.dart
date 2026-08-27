import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class RunHistoryScreen extends StatelessWidget {
  const RunHistoryScreen({super.key});

  Future<List<dynamic>> _buscarHistorico(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8080/api/usuarios/$idUsuario/perfil'),
    );

    if (response.statusCode == 200) {
      final dados = json.decode(utf8.decode(response.bodyBytes));
      return dados['historico'] ?? [];
    } else {
      throw Exception('Erro ao carregar histórico');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<dynamic>>(
        future: _buscarHistorico(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Falha ao carregar atividades do servidor",
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final corridas = snapshot.data ?? [];

          if (corridas.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum experimento registrado ainda 🧪",
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: corridas.length,
            itemBuilder: (context, index) {
              final corrida = corridas[index];
              final double km = (corrida["km"] as num? ?? 0.0).toDouble();

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
                        Row(
                          children: [
                            Text(
                              corrida["dataHora"] ?? "",
                              style: const TextStyle(
                                color: Color(0xFF06B6D4),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF06B6D4,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "+${corrida["xpGanho"]} XP",
                                style: const TextStyle(
                                  color: Color(0xFF06B6D4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${km.toStringAsFixed(2)} km",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          corrida["tipo"] ?? "Corrida",
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildStatRow(
                          Icons.timer_outlined,
                          corrida["tempo"] ?? "00:00",
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          Icons.speed,
                          "${corrida["pace"] ?? "0:00"} /km",
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
