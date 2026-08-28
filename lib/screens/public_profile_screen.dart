import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/user_provider.dart';

class PublicProfileScreen extends StatefulWidget {
  final Map<String, dynamic> usuarioAlvo;

  const PublicProfileScreen({super.key, required this.usuarioAlvo});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  bool _isLoadingFollowAction = false;
  bool _isFollowing = false;
  bool _isLoadingStatus = true;
  late Future<Map<String, dynamic>> _perfilFuture;
  int? _seguidoresTempoReal;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus(); // Checa se já segue
    _perfilFuture = _carregarPerfil(); // Busca os dados completos da API
  }

  Future<Map<String, dynamic>> _carregarPerfil() async {
    final idAlvo = widget.usuarioAlvo['id'];
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8080/api/usuarios/$idAlvo/perfil'),
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Falha ao carregar o perfil da API');
    }
  }

  Future<void> _checkFollowStatus() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idLogado = userProvider.usuarioLogado?.id ?? 1;
    final idAlvo = widget.usuarioAlvo['id'];

    final url = Uri.parse(
      'http://127.0.0.1:8080/api/social/$idLogado/segue/$idAlvo',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _isFollowing = json.decode(response.body) == true;
          _isLoadingStatus = false;
        });
      } else {
        setState(() => _isLoadingStatus = false);
      }
    } catch (e) {
      debugPrint("Erro ao checar status de seguir: $e");
      setState(() => _isLoadingStatus = false);
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => _isLoadingFollowAction = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idLogado = userProvider.usuarioLogado?.id ?? 1;
    final idAlvo = widget.usuarioAlvo['id'];

    final url = Uri.parse(
      'http://127.0.0.1:8080/api/social/$idLogado/seguir/$idAlvo',
    );

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        setState(() {
          _isFollowing = !_isFollowing;
          _isLoadingFollowAction = false;

          // NOVO 2/3: A matemática que atualiza o número instantaneamente
          if (_seguidoresTempoReal != null) {
            if (_isFollowing) {
              _seguidoresTempoReal =
                  _seguidoresTempoReal! + 1; // Ganhou seguidor
            } else {
              _seguidoresTempoReal =
                  _seguidoresTempoReal! - 1; // Perdeu seguidor
            }
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.body),
            backgroundColor: const Color(0xFF06B6D4),
          ),
        );
      } else {
        setState(() => _isLoadingFollowAction = false);
      }
    } catch (e) {
      setState(() => _isLoadingFollowAction = false);
      debugPrint("Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _perfilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Erro ao carregar perfil público",
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final perfilAPI = snapshot.data!;

          // NOVO 3/3: Define o número inicial do banco apenas na primeira renderização
          _seguidoresTempoReal ??= perfilAPI['seguidores'] ?? 0;

          // Extraindo os dados da API (Single Source of Truth)
          final nome =
              perfilAPI['nome'] ?? widget.usuarioAlvo['nome'] ?? 'Usuário';
          final avatar =
              perfilAPI['avatar'] ?? widget.usuarioAlvo['avatar'] ?? '🧪';
          final role =
              widget.usuarioAlvo['role'] ??
              'Atleta'; // Mantido do argumento inicial

          final String bioReal =
              perfilAPI['bio'] ??
              "Olá! Sou um entusiasta do FitLab e estou aqui para experimentar novas rotinas de treino.";
          final int nivelAtual = perfilAPI['nivel']?['levelAtual'] ?? 1;
          final int qtdTreinos = (perfilAPI['historico'] as List?)?.length ?? 0;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // CABEÇALHO DO PERFIL
              SliverAppBar(
                expandedHeight: 280.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF1A1A1A),
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1D4ED8), Color(0xFF0D0D0D)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: const Color(
                            0xFF06B6D4,
                          ).withOpacity(0.2),
                          child: Text(
                            avatar,
                            style: const TextStyle(
                              color: Color(0xFF06B6D4),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF06B6D4),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // CORPO DO PERFIL
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BOTÃO DE SEGUIR
                      Center(
                        child: _isLoadingStatus
                            ? const CircularProgressIndicator(
                                color: Color(0xFF06B6D4),
                              )
                            : SizedBox(
                                width: 220,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: _isLoadingFollowAction
                                      ? null
                                      : _toggleFollow,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isFollowing
                                        ? Colors.transparent
                                        : const Color(0xFF06B6D4),
                                    side: _isFollowing
                                        ? const BorderSide(
                                            color: Color(0xFF06B6D4),
                                          )
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: _isLoadingFollowAction
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          _isFollowing ? 'SEGUINDO' : 'SEGUIR',
                                          style: TextStyle(
                                            color: _isFollowing
                                                ? const Color(0xFF06B6D4)
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                ),
                              ),
                      ),

                      const SizedBox(height: 32),

                      // ESTATÍSTICAS REAIS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn("$nivelAtual", "NÍVEL"),
                          _buildVerticalDivider(),
                          // Usa a nossa variável dinâmica aqui:
                          _buildStatColumn(
                            "$_seguidoresTempoReal",
                            "SEGUIDORES",
                          ),
                          _buildVerticalDivider(),
                          _buildStatColumn("$qtdTreinos", "TREINOS"),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // BIOGRAFIA REAL
                      const Text(
                        "BIOGRAFIA",
                        style: TextStyle(
                          color: Color(0xFF06B6D4),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        bioReal,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // MEDALHAS RECENTES (Pode ser integrado depois)
                      const Text(
                        "CONQUISTAS RECENTES",
                        style: TextStyle(
                          color: Color(0xFF06B6D4),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildBadge(
                            "🔥",
                            "Streak ${perfilAPI['streak'] ?? 0} Dias",
                          ),
                          const SizedBox(width: 12),
                          _buildBadge("🏃‍♂️", "Ativo"),
                          const SizedBox(width: 12),
                          _buildBadge("🥇", "Membro"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.white10);
  }

  Widget _buildBadge(String icon, String title) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
