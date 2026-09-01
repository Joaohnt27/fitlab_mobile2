import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../config/api_constants.dart';
import 'challenge_details_screen.dart'; 

class AllChallengesScreen extends StatefulWidget {
  const AllChallengesScreen({super.key});

  @override
  State<AllChallengesScreen> createState() => _AllChallengesScreenState();
}

class _AllChallengesScreenState extends State<AllChallengesScreen> {
  Future<List<Map<String, dynamic>>> _fetchMappedChallenges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;

    try {
      final resGlobais = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/desafios'),
      );
      final resAtivos = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/usuarios/$idUsuario/desafios'),
      );
      final resBadges = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/usuarios/$idUsuario/badges'),
      );

      List<dynamic> globais = [];
      List<dynamic> ativos = [];
      List<dynamic> badges = [];

      if (resGlobais.statusCode == 200)
        globais = json.decode(utf8.decode(resGlobais.bodyBytes));
      if (resAtivos.statusCode == 200)
        ativos = json.decode(utf8.decode(resAtivos.bodyBytes));
      if (resBadges.statusCode == 200)
        badges = json.decode(utf8.decode(resBadges.bodyBytes));

      List<Map<String, dynamic>> mappedList = [];

      for (var desafio in globais) {
        final id = desafio['id'];
        final nomeBadgeExclusiva = desafio['badgeExclusiva']?.toString().trim();

        // 1. Verifica se já concluiu (Tem a insígnia)
        bool isConcluido = badges.any(
          (b) =>
              b['unlocked'] == true &&
              b['name'] != null &&
              b['name'].toString().trim() == nomeBadgeExclusiva,
        );

        // 2. Verifica se está em andamento
        var ativoData = ativos.firstWhere(
          (a) =>
              (a['id'] == id ||
              (a['desafio'] != null && a['desafio']['id'] == id)),
          orElse: () => null,
        );

        bool isEmAndamento = ativoData != null;
        double progress = 0.0;
        double total = (desafio['objetivoKm'] ?? desafio['total'] ?? 1)
            .toDouble();

        if (isConcluido) {
          progress = total; // Força 100% se já fechou
        } else if (isEmAndamento) {
          progress = (ativoData['progressoAtual'] ?? ativoData['progress'] ?? 0)
              .toDouble();
        }

        // Mapeando um emoji legal baseado no ícone do banco de dados
        String iconeVisual = "🏆";
        if (desafio['imagem'] == 'bolt') iconeVisual = "⚡";
        if (desafio['imagem'] == 'nightlight_round') iconeVisual = "🌃";
        if (desafio['imagem'] == 'map') iconeVisual = "🗺️";

        mappedList.add({
          "rawData":
              desafio, // Guarda o dado original para passar pra próxima tela
          "title": desafio['titulo'] ?? desafio['title'] ?? 'Desafio',
          "theme": desafio['modalidadeAlvo'] ?? 'Laboratório',
          "desc":
              desafio['descricao'] ?? desafio['desc'] ?? 'Supere seus limites',
          "icon": iconeVisual,
          "progress": progress,
          "total": total,
          "isConcluido": isConcluido,
          "isEmAndamento": isEmAndamento,
        });
      }
      return mappedList;
    } catch (e) {
      debugPrint("Erro ao carregar desafios: $e");
      return [];
    }
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMappedChallenges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Erro ao carregar o catálogo.",
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final desafiosMapeados = snapshot.data ?? [];

          if (desafiosMapeados.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum desafio criado no laboratório ainda.",
                style: TextStyle(color: Colors.white38),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: desafiosMapeados.length,
            itemBuilder: (context, index) {
              final c = desafiosMapeados[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () async {
                    // 👇 Agora navega para a tela de detalhes que construímos!
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChallengeDetailsScreen(desafio: c['rawData']),
                      ),
                    );
                    // Força o reload da tela ao voltar, caso o status tenha mudado
                    setState(() {});
                  },
                  child: _buildPremiumTile(c),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPremiumTile(Map<String, dynamic> c) {
    final String icon = c['icon'];
    final String theme = c['theme'];
    final String title = c['title'];
    final String desc = c['desc'];
    final double progress = c['progress'];
    final double total = c['total'];
    final bool isConcluido = c['isConcluido'];
    final bool isEmAndamento = c['isEmAndamento'];

    final double progressPercent = total > 0
        ? (progress / total).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          // 👇 Borda verde se concluiu, Ciano se aceitou, invisível se não aceitou
          color: isConcluido
              ? Colors.green.withOpacity(0.3)
              : (isEmAndamento
                    ? const Color(0xFF06B6D4).withOpacity(0.3)
                    : Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isConcluido
                  ? Colors.green.withOpacity(0.1)
                  : (isEmAndamento
                        ? const Color(0xFF06B6D4).withOpacity(0.1)
                        : Colors.white.withOpacity(0.05)),
              shape: BoxShape.circle,
            ),
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theme.toUpperCase(),
                  style: TextStyle(
                    // 👇 Título verde se concluído
                    color: isConcluido ? Colors.green : const Color(0xFF06B6D4),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 12),
                // 👇 Barra de progresso visível sempre (ajuda a dar vontade de fazer)
                LinearProgressIndicator(
                  value: progressPercent,
                  backgroundColor: Colors.white10,
                  color: isConcluido ? Colors.green : const Color(0xFF06B6D4),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            isConcluido ? Icons.check_circle : Icons.arrow_forward_ios,
            color: isConcluido ? Colors.green : Colors.white10,
            size: isConcluido ? 24 : 14,
          ),
        ],
      ),
    );
  }
}
