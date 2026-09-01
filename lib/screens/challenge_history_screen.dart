import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/user_provider.dart';
import '../config/api_constants.dart';
import 'challenge_details_screen.dart'; // Para poder clicar e abrir o desafio

class ChallengeHistoryScreen extends StatefulWidget {
  const ChallengeHistoryScreen({super.key});

  @override
  State<ChallengeHistoryScreen> createState() => _ChallengeHistoryScreenState();
}

class _ChallengeHistoryScreenState extends State<ChallengeHistoryScreen> {
  int _activeFilter = 0; // 0: Todos, 1: Ativos, 2: Finalizados

  Future<List<Map<String, dynamic>>> _fetchMappedChallenges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;

    try {
      // 1. Busca Catálogo de Desafios Global
      final resGlobais = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/desafios'),
      );
      // 2. Busca Desafios que o usuário aceitou (Em andamento)
      final resAtivos = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/usuarios/$idUsuario/desafios'),
      );
      // 3. Busca Badges (Para saber quais ele já fechou)
      final resBadges = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/usuarios/$idUsuario/badges'),
      );

      List<dynamic> globais = [];
      List<dynamic> ativos = [];
      List<dynamic> badges = [];

      if (resGlobais.statusCode == 200) {
        globais = json.decode(utf8.decode(resGlobais.bodyBytes));
      }
      if (resAtivos.statusCode == 200) {
        ativos = json.decode(utf8.decode(resAtivos.bodyBytes));
      }
      if (resBadges.statusCode == 200) {
        badges = json.decode(utf8.decode(resBadges.bodyBytes));
      }

      List<Map<String, dynamic>> mappedList = [];

      for (var desafio in globais) {
        final id = desafio['id'];
        final nomeBadgeExclusiva = desafio['badgeExclusiva']?.toString().trim();

        bool isConcluido = badges.any(
          (b) =>
              b['unlocked'] == true &&
              b['name'] != null &&
              b['name'].toString().trim() == nomeBadgeExclusiva,
        );

        bool isEmAndamento = ativos.any(
          (a) =>
              (a['id'] == id ||
              (a['desafio'] != null && a['desafio']['id'] == id)),
        );

        int type = 0; // 0 = Não iniciado
        if (isConcluido) {
          type = 2; // Finalizado
        } else if (isEmAndamento) {
          type = 1; // Em Curso
        }

        mappedList.add({
          "rawData": desafio,
          "title": desafio['titulo'] ?? 'Desafio',
          "target": desafio['modalidadeAlvo'] ?? 'Corrida',
          "xp": desafio['recompensaXp'] ?? 0,
          "type": type,
        });
      }

      return mappedList;
    } catch (e) {
      debugPrint("Erro ao buscar histórico: $e");
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
          Expanded(child: _buildRealChallengeList()),
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

  Widget _buildRealChallengeList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchMappedChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "Nenhum desafio encontrado.",
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        final allChallenges = snapshot.data!;
        final filtered = _activeFilter == 0
            ? allChallenges
            : allChallenges.where((c) => c['type'] == _activeFilter).toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              "Nenhum desafio nesta categoria.",
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final item = filtered[index];
            bool isCompleted = item['type'] == 2;
            bool isActive = item['type'] == 1;

            return GestureDetector(
              onTap: () async {
                // Ao clicar, abre a tela de detalhes e recarrega a lista ao voltar
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChallengeDetailsScreen(desafio: item['rawData']),
                  ),
                );
                setState(
                  () {},
                ); // Força recarregar caso ele tenha aceitado um novo
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.3)
                        : (isActive
                              ? const Color(0xFF06B6D4).withOpacity(0.2)
                              : Colors.white.withOpacity(0.03)),
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: isCompleted ? 1.0 : (isActive ? 0.6 : 0.0),
                          strokeWidth: 2,
                          color: isCompleted
                              ? Colors.green
                              : (isActive
                                    ? const Color(0xFF06B6D4)
                                    : Colors.white10),
                          backgroundColor: Colors.white.withOpacity(0.05),
                        ),
                        Icon(
                          isCompleted
                              ? Icons.check_circle_rounded
                              : (isActive
                                    ? Icons.bolt_rounded
                                    : Icons.lock_outline_rounded),
                          color: isCompleted
                              ? Colors.green
                              : (isActive
                                    ? const Color(0xFF06B6D4)
                                    : Colors.white24),
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
                            item['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${item['target']} • ${item['xp']} XP",
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: isCompleted
                          ? Colors.green.withOpacity(0.5)
                          : Colors.white10,
                      size: 14,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
