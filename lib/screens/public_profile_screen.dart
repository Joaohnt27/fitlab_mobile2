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

  @override
  void initState() {
    super.initState();
    _checkFollowStatus(); // Checa se já segue logo ao abrir a tela!
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
    final nome = widget.usuarioAlvo['nome'] ?? 'Usuário';
    final role = widget.usuarioAlvo['role'] ?? 'Atleta';
    final avatar = widget.usuarioAlvo['avatar'] ?? 'FIT';

    // Dados visuais que futuramente viremos de um "PerfilCompletoDTO" do Java
    final bio = role == 'Treinador'
        ? "Transformando suor em resultados. Especialista em hipertrofia e emagrecimento."
        : "Sempre em busca do próximo quilômetro. Movido a desafios!";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
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
                      backgroundColor: const Color(0xFF06B6D4).withOpacity(0.2),
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
                  // BOTÃO DE SEGUIR CENTRALIZADO E INTELIGENTE
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
                                    ? const BorderSide(color: Color(0xFF06B6D4))
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

                  // ESTATÍSTICAS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn("12", "NÍVEL"),
                      _buildVerticalDivider(),
                      _buildStatColumn("84", "SEGUIDORES"),
                      _buildVerticalDivider(),
                      _buildStatColumn("45", "TREINOS"),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // BIOGRAFIA
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
                    bio,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // MEDALHAS RECENTES (Mock visual por enquanto)
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
                      _buildBadge("🔥", "Streak 7 Dias"),
                      const SizedBox(width: 12),
                      _buildBadge("🏃‍♂️", "10km Run"),
                      const SizedBox(width: 12),
                      _buildBadge("🥇", "Mestre Jedi"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
