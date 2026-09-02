import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../config/api_constants.dart';
import 'subscription_screen.dart'; // Importe a tela de assinaturas

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int? _treinadorVinculadoId;
  // Chamada de API para buscar o ranking
  Future<List<dynamic>> _fetchRankingGlobal() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/usuarios/ranking');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        throw Exception('Falha ao carregar ranking');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<dynamic>> _fetchTreinadores() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/usuarios/treinadores');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        throw Exception('Falha ao carregar treinadores');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // 👇 LÓGICA DE REQUISIÇÃO COM LOGS APRIMORADOS 👇
  Future<void> _vincularTreinador(BuildContext context, int treinadorId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final atletaId = userProvider.usuarioLogado?.id;

    if (atletaId == null) {
      debugPrint("❌ ERRO: Atleta ID está nulo (Usuário não logado?)");
      return;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/mentorias/vincular');

    // MONTANDO O PACOTE
    final payload = {"atleta_id": atletaId, "treinador_id": treinadorId};
    debugPrint("📦 ENVIANDO PAYLOAD PARA O JAVA: $payload");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(payload),
      );

      debugPrint(
        "📥 RESPOSTA DO JAVA: Status ${response.statusCode} | Body: ${response.body}",
      );

      // Fecha o Modal do Perfil do Treinador se ainda estiver aberto
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200) {
        if (context.mounted) {
          setState(() {
            _treinadorVinculadoId = treinadorId;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mentoria ativada com sucesso por 30 dias!"),
              backgroundColor: Color(0xFF06B6D4),
            ),
          );
        }
      } else if (response.statusCode == 403 ||
          response.body.contains('PAYWALL')) {
        if (context.mounted) _mostrarPaywallMentoria(context);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.body),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ ERRO HTTP: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("O sistema está offline no momento."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // 👇 BOTTOM SHEET COM EXTRAÇÃO BLINDADA DO ID 👇
  void _abrirPerfilTreinador(
    BuildContext context,
    Map<String, dynamic> treinador,
  ) {
    debugPrint(
      "🔍 DADOS BRUTOS DO TREINADOR RECEBIDOS DA API: $treinador",
    ); // <-- OLHE ISSO NO CONSOLE!

    // Extração à prova de falhas: procura por vários nomes de chaves comuns do JPA
    dynamic rawId =
        treinador['id'] ?? treinador['idUsuario'] ?? treinador['id_user'];

    int treinadorId = 0;
    if (rawId != null) {
      treinadorId = int.tryParse(rawId.toString()) ?? 0;
    }

    debugPrint("🎯 ID EXTRAÍDO E CONVERTIDO: $treinadorId");

    // Trava de segurança no app
    if (treinadorId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Erro: ID do treinador inválido ou não enviado pela API.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Nem tenta enviar para o Java!
    }

    final nome = treinador['nome'] ?? 'Treinador Especialista';
    final bio =
        treinador['bioUsuario'] ??
        treinador['biografia'] ??
        'Olá! Estou aqui para otimizar a sua performance.';
    final avatar = treinador['avatar'] ?? '👨‍🏫';
    final rating = 5.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white10,
                    child: Text(avatar, style: const TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF06B6D4),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.groups, color: Colors.white38, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        "Coach Elite",
                        style: TextStyle(color: Colors.white38),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xFF06B6D4),
                        )
                      : _treinadorVinculadoId == treinadorId
                      ? SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: null, // Desabilita o clique totalmente!
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "MENTORIA ATIVA",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: Colors.green.withOpacity(
                                0.4,
                              ),
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              setStateSheet(() => isLoading = true);
                              await _vincularTreinador(context, treinadorId);
                              // Caso o modal não feche, removemos o loading
                              if (context.mounted) {
                                setStateSheet(() => isLoading = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF06B6D4),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "SOLICITAR MENTORIA (30 DIAS)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 👇 PAYWALL EXCLUSIVO PARA O PLANO ELITE 👇
  void _mostrarPaywallMentoria(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, color: Colors.amber, size: 56),
            const SizedBox(height: 24),
            const Text(
              "MENTORIA EXCLUSIVA",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Apenas Atletas do plano ELITE possuem acesso à contratação de treinadores humanos em tempo real.\n\nFaça o upgrade para destravar a mentoria e maximizar sua performance.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "CONHECER O PLANO ELITE",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: _buildSearchBar(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: _buildMyRankCard(context),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                const TabBar(
                  indicatorColor: Color(0xFF06B6D4),
                  indicatorWeight: 3,
                  labelColor: Color(0xFF06B6D4),
                  unselectedLabelColor: Colors.white38,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  tabs: [
                    Tab(text: "GLOBAL"),
                    Tab(text: "AMIGOS"),
                    Tab(text: "TREINADORES"),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                children: [
                  _buildGlobalTab(),
                  _buildFriendsTab(),
                  _buildTrainersTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A1A),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          "COMUNIDADE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1D4ED8), Color(0xFF0D0D0D)],
            ),
          ),
          child: const Opacity(
            opacity: 0.1,
            child: Icon(Icons.groups_outlined, size: 100, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Buscar atletas ou treinadores...",
          hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: Color(0xFF06B6D4), size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildMyRankCard(BuildContext context) {
    final user = Provider.of<UserProvider>(context).usuarioLogado;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MINHA POSIÇÃO",
            style: TextStyle(
              color: Color(0xFF06B6D4),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatColumn(label: "RANK", value: "#${user?.ranking ?? '--'}"),
              _StatColumn(
                label: "TREINOS",
                value: "${user?.totalTreinos ?? 0}",
              ),
              _StatColumn(label: "FITPOINTS", value: "${user?.fitpoints ?? 0}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalTab() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchRankingGlobal(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Erro ao carregar o ranking. Tente novamente.",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }
        final atletas = snapshot.data ?? [];
        if (atletas.isEmpty) {
          return const Center(
            child: Text(
              "O Laboratório está vazio.",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 120,
          ),
          itemCount: atletas.length,
          itemBuilder: (context, index) {
            final atleta = atletas[index];
            return _RankingTile(
              index: index,
              name: atleta['nome'] ?? "Atleta",
              avatar: atleta['avatar'] ?? "🧪",
              pontos: atleta['fitPoints'] ?? 0,
              patente: atleta['nomePatente'] ?? "Recruta",
            );
          },
        );
      },
    );
  }

  Widget _buildFriendsTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: 4,
            itemBuilder: (context, index) =>
                _RankingTile(index: index, name: "Amigo Atleta"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 0,
            bottom: 120,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text(
                "ADICIONAR AMIGOS",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF06B6D4),
                side: const BorderSide(color: Color(0xFF06B6D4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainersTab(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchTreinadores(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
          );
        }

        final treinadores = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 120,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1D4ED8).withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF06B6D4),
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Encontre treinadores profissionais e certificados para acelerar seus resultados",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (treinadores.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Nenhum treinador cadastrado ainda.",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              ...treinadores.map((t) {
                int index = treinadores.indexOf(t);
                return _RankingTile(
                  index: index,
                  name: t['nome'] ?? "Treinador",
                  avatar: t['avatar'] ?? "👨‍🏫",
                  isTrainer: true,
                  specialty: t['nomePatente'] ?? "Performance",
                  rating: 5.0,
                  students: 0,
                  // 👇 AQUI PASSAMOS O MAP INTEIRO DO TREINADOR E A AÇÃO DE CLIQUE 👇
                  onTap: () => _abrirPerfilTreinador(context, t),
                );
              }),
          ],
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
      ],
    );
  }
}

class _RankingTile extends StatelessWidget {
  final int index;
  final String name;
  final String? avatar;
  final int? pontos;
  final String? patente;
  final bool isTrainer;
  final String? specialty;
  final double rating;
  final int students;
  final VoidCallback? onTap; // Adicionado para receber o clique externamente

  const _RankingTile({
    super.key,
    required this.index,
    required this.name,
    this.avatar,
    this.pontos,
    this.patente,
    this.isTrainer = false,
    this.specialty,
    this.rating = 0.0,
    this.students = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.white.withOpacity(0.05);
    Widget rankIcon = Text(
      "${index + 1}",
      style: const TextStyle(
        color: Color(0xFF06B6D4),
        fontWeight: FontWeight.bold,
      ),
    );
    double borderWidth = 1;

    if (!isTrainer) {
      if (index == 0) {
        borderColor = const Color(0xFFFFD700).withOpacity(0.6);
        rankIcon = const Text("🥇", style: TextStyle(fontSize: 18));
        borderWidth = 2;
      } else if (index == 1) {
        borderColor = const Color(0xFFC0C0C0).withOpacity(0.6);
        rankIcon = const Text("🥈", style: TextStyle(fontSize: 18));
        borderWidth = 1.5;
      } else if (index == 2) {
        borderColor = const Color(0xFFCD7F32).withOpacity(0.6);
        rankIcon = const Text("🥉", style: TextStyle(fontSize: 18));
        borderWidth = 1.5;
      }
    }

    return GestureDetector(
      // 👇 Chama a função passada pelo pai (que abre o perfil)
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isTrainer) SizedBox(width: 30, child: Center(child: rankIcon)),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white10,
              child: Text(
                isTrainer ? "👨‍🏫" : (avatar ?? "🧪"),
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (isTrainer) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: Color(0xFF06B6D4),
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTrainer
                        ? (specialty ?? "Consultoria")
                        : (patente ?? "Atleta FitLab"),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  if (isTrainer) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.groups,
                          color: Colors.white38,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$students alunos",
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!isTrainer && pontos != null) ...[
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$pontos",
                    style: const TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "FP",
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ],
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white10),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFF0D0D0D), child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
