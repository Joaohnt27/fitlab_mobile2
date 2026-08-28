import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/user_provider.dart';
import '../config/api_constants.dart';

class ChallengeDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> desafio;

  const ChallengeDetailsScreen({super.key, required this.desafio});

  @override
  State<ChallengeDetailsScreen> createState() => _ChallengeDetailsScreenState();
}

class _ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
  bool _isLoadingAction = false;
  bool _isLoadingStatus = true;
  bool _aceito = false;

  @override
  void initState() {
    super.initState();
    _checkChallengeStatus(); // Chama a verificação inicial!
  }

  // NOVA FUNÇÃO: Checa se o usuário já tem esse desafio ativo
  Future<void> _checkChallengeStatus() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;
    final idDesafio = widget.desafio['id'];

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/feed/desafios/$idDesafio/status/$idUsuario',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _aceito = json.decode(response.body) == true;
          _isLoadingStatus = false;
        });
      } else {
        setState(() => _isLoadingStatus = false);
      }
    } catch (e) {
      debugPrint("Erro ao checar status do desafio: $e");
      setState(() => _isLoadingStatus = false);
    }
  }

  Future<void> _aceitarDesafio() async {
    setState(() => _isLoadingAction = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;
    final idDesafio = widget.desafio['id'];

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/feed/desafios/$idDesafio/aceitar/$idUsuario',
    );

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        setState(() {
          _aceito = true;
          _isLoadingAction = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Desafio aceito! Bom treino!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isLoadingAction = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.body),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Agora puxamos as descrições e badges direto do Mapa!
    final title = widget.desafio['titulo'] ?? 'Desafio';
    final descricao = widget.desafio['descricao'] ?? 'Sem descrição.';
    final badge = widget.desafio['badgeExclusiva'] ?? '🏅 Insígnia Secreta';
    final xp = widget.desafio['recompensaXp']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com Ícone e Título
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Color(0xFF06B6D4),
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "RECOMPENSA: $xp XP",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Descrição da Missão
            const Text(
              "OBJETIVO DA MISSÃO",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              descricao,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Badge Exclusiva
            const Text(
              "BADGE EXCLUSIVA",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified,
                    color: Color(0xFF06B6D4),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Botão Gigante de Ação (Inteligente)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _isLoadingStatus
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF06B6D4),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _aceito || _isLoadingAction
                          ? null
                          : _aceitarDesafio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _aceito
                            ? Colors.green
                            : const Color(0xFF06B6D4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoadingAction
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _aceito ? "DESAFIO ACEITO" : "ACEITAR DESAFIO",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
