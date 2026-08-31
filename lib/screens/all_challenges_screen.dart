import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../config/api_constants.dart';

class AllChallengesScreen extends StatefulWidget {
  // 1. Construtor limpo! Não precisamos mais receber dados estáticos.
  const AllChallengesScreen({super.key});

  @override
  State<AllChallengesScreen> createState() => _AllChallengesScreenState();
}

class _AllChallengesScreenState extends State<AllChallengesScreen> {
  // 2. Busca TODOS os desafios disponíveis no banco de dados (Catálogo Geral)
  Future<List<dynamic>> _fetchAllChallenges() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/desafios');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        throw Exception('Falha ao carregar catálogo de desafios');
      }
    } catch (e) {
      debugPrint("Erro de conexão: $e");
      return [];
    }
  }

  // 3. A Lógica de Aceitar o Desafio conectada à API
  Future<void> _aceitarDesafio(BuildContext context, int idDesafio) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/usuarios/$idUsuario/desafios/$idDesafio',
    );

    try {
      // Exibe um loading para dar feedback visual
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
        ),
      );

      final response = await http.post(url);

      // Fecha o loading
      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Desafio Aceito! Boa sorte!"),
            backgroundColor: Colors.green,
          ),
        );

        // Atualiza a tela de WorkoutsScreen (Laboratório) em segundo plano
        await userProvider.recarregarUsuario();

        // Fecha o Modal do Desafio
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Aviso: ${response.body}"),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Fecha loading
      debugPrint("Erro ao aceitar desafio: $e");
    }
  }

  // Função para mostrar a insígnia e o botão de aceitar
  void _showRewardDetails(
    BuildContext context,
    Map<String, dynamic> challenge,
  ) {
    // Tratamento de segurança caso a API não envie o campo
    final String reward =
        challenge['reward'] ?? challenge['recompensa'] ?? "INSÍGNIA EXCLUSIVA";
    final String title = challenge['title'] ?? challenge['titulo'] ?? "Desafio";
    final int idDesafio = challenge['id'] ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            reward.toUpperCase(),
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
              const Text("🏆", style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                "Ao completar o desafio '$title', você desbloqueará esta insígnia exclusiva no seu perfil!",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "FECHAR",
                style: TextStyle(color: Colors.white38),
              ),
            ),
            ElevatedButton(
              onPressed: () => _aceitarDesafio(context, idDesafio),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "ACEITAR DESAFIO",
                style: TextStyle(fontWeight: FontWeight.bold),
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
      body: FutureBuilder<List<dynamic>>(
        future: _fetchAllChallenges(),
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

          final desafiosDaAPI = snapshot.data ?? [];

          if (desafiosDaAPI.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum desafio criado no laboratório ainda.",
                style: TextStyle(color: Colors.white38),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: desafiosDaAPI.length,
            itemBuilder: (context, index) {
              final c = desafiosDaAPI[index] as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () => _showRewardDetails(context, c),
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
    // Blindagem e tradução de tipos para evitar telas vermelhas
    final String icon = c['icon'] ?? c['icone'] ?? "🏆";
    final String theme = c['theme'] ?? c['tema'] ?? "DESAFIO";
    final String title = c['title'] ?? c['titulo'] ?? "Novo Desafio";
    final String desc = c['desc'] ?? c['descricao'] ?? "Supere seus limites";
    final double progress = (c['progress'] ?? c['progresso'] ?? 0).toDouble();
    final double total = (c['total'] ?? 1).toDouble();
    final double progressPercent = (progress / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theme.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF06B6D4),
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
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressPercent,
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
