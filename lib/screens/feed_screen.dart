import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitlab_mobile2/widgets/feed_level_radial.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/feed_card.dart';
import '../models/feed_item.dart';
import '../widgets/suggest_user_card.dart';
import '../widgets/trending_challenge_card.dart';
import '../widgets/streak_meter.dart';
import '../config/api_constants.dart';
import '../widgets/profile_level_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // Variáveis de Estado para o "Quem Seguir"
  List<dynamic> _sugestoesDb = [];
  bool _isLoadingSugestoes = true;

  // Variáveis para os Desafios
  List<dynamic> _desafiosDb = [];
  bool _isLoadingDesafios = true;

  // Variáveis para o Feed Social
  List<dynamic> _feedDb = [];
  bool _isLoadingFeed = true;

  Map<String, dynamic>? _meuNivelData;

  // 👇 Variáveis para o Experimento Ativo 👇
  Map<String, dynamic>? _experimentoAtivo;
  bool _isLoadingExperimento = true;

  // Paginação
  int _page = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    // chama a função de busca logo que a tela abre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSugestoes();
      _fetchDesafios();
      _fetchFeed(isRefresh: true);
      _fetchMeuNivel();
      _fetchExperimentoAtivo(); // 👈 Inicia a busca do experimento ao abrir o feed!
    });
  }

  // 👇 NOVA FUNÇÃO: Busca o experimento real no banco 👇
  Future<void> _fetchExperimentoAtivo() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/usuarios/$idUsuario/experimentos/ativo',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        if (mounted) {
          setState(() {
            _experimentoAtivo = json.decode(utf8.decode(response.bodyBytes));
            _isLoadingExperimento = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _experimentoAtivo = null;
            _isLoadingExperimento = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar experimento ativo no feed: $e");
      if (mounted) setState(() => _isLoadingExperimento = false);
    }
  }

  Future<void> _fetchMeuNivel() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.usuarioLogado?.id ?? 1;
    final url = Uri.parse('${ApiConstants.baseUrl}/usuarios/$userId/perfil');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dados = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _meuNivelData = dados['nivel']; // Extrai apenas o bloco de XP
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar nível para o Feed: $e");
    }
  }

  Future<void> _fetchSugestoes() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.usuarioLogado?.id ?? 1;
    final url = Uri.parse('${ApiConstants.baseUrl}/feed/sugestoes/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _sugestoesDb = json.decode(utf8.decode(response.bodyBytes));
          _isLoadingSugestoes = false;
        });
      } else {
        setState(() => _isLoadingSugestoes = false);
      }
    } catch (e) {
      debugPrint("Erro ao buscar sugestões: $e");
      setState(() => _isLoadingSugestoes = false);
    }
  }

  Future<void> _fetchDesafios() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/feed/desafios-em-alta');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _desafiosDb = json.decode(utf8.decode(response.bodyBytes));
          _isLoadingDesafios = false;
        });
      } else {
        setState(() => _isLoadingDesafios = false);
      }
    } catch (e) {
      debugPrint("Erro ao buscar desafios: $e");
      setState(() => _isLoadingDesafios = false);
    }
  }

  Future<void> _fetchFeed({bool isRefresh = false}) async {
    if (isRefresh) {
      _page = 0;
      _hasMore = true;
      if (mounted) setState(() => _isLoadingFeed = true);
    } else {
      if (mounted) setState(() => _isLoadingMore = true);
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.usuarioLogado?.id ?? 1;

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/feed/social/$userId?page=$_page',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List novosPosts = json.decode(utf8.decode(response.bodyBytes));

        if (mounted) {
          setState(() {
            if (isRefresh) {
              _feedDb = novosPosts;
            } else {
              _feedDb.addAll(novosPosts);
            }

            _isLoadingFeed = false;
            _isLoadingMore = false;

            if (novosPosts.length < 10) {
              _hasMore = false;
            } else {
              _page++;
            }
          });
        }
      } else {
        if (mounted)
          setState(() {
            _isLoadingFeed = false;
            _isLoadingMore = false;
          });
      }
    } catch (e) {
      debugPrint("Erro ao buscar feed: $e");
      if (mounted)
        setState(() {
          _isLoadingFeed = false;
          _isLoadingMore = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A1A),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              collapseMode: CollapseMode.parallax,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: const Text(
                "FEED FITLAB",
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
                  opacity: 0.3,
                  child: Icon(
                    Icons.people_alt_outlined,
                    size: 100,
                    color: Colors.white10,
                  ),
                ),
              ),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: StreakMeter(),
              ),
            ],
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 20, left: 24, right: 24),
              child: Text(
                "Acompanhe outros usuários do FitLab",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: _meuNivelData == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF06B6D4),
                      ),
                    )
                  : ProfileLevelCard(nivelData: _meuNivelData!),
            ),
          ),

          // 👇 SEÇÃO DO EXPERIMENTO ATIVO CONECTADA AO BANCO 👇
          SliverToBoxAdapter(
            child: _isLoadingExperimento
                ? const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF06B6D4),
                      ),
                    ),
                  )
                : (_experimentoAtivo == null)
                ? Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: const Text(
                      "Nenhum experimento ativo. Vá ao laboratório!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    ),
                  )
                : Builder(
                    builder: (context) {
                      // Extraindo dados da API
                      final String volumeMetaStr =
                          _experimentoAtivo!['volume']?.toString() ?? "0";
                      final double progressoReal =
                          (_experimentoAtivo!['progresso'] ?? 0.0).toDouble();

                      double kmMetaNumerico =
                          double.tryParse(
                            volumeMetaStr.replaceAll(RegExp(r'[^0-9.]'), ''),
                          ) ??
                          0.0;
                      double kmAtual = kmMetaNumerico * progressoReal;

                      // Lógica do DataFim para os dias restantes
                      String diasRestantesFormatados = "0";
                      if (_experimentoAtivo!['dataFim'] != null) {
                        try {
                          DateTime dataFim = DateTime.parse(
                            _experimentoAtivo!['dataFim'],
                          );
                          int dias = dataFim.difference(DateTime.now()).inDays;
                          diasRestantesFormatados = (dias > 0 ? dias : 0)
                              .toString();
                        } catch (e) {
                          diasRestantesFormatados =
                              _experimentoAtivo!['frequencia']?.toString() ??
                              "0";
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF06B6D4).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "ANDAMENTO DO EXPERIMENTO",
                                  style: TextStyle(
                                    color: Color(0xFF06B6D4),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  "$diasRestantesFormatados dias restantes",
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${kmAtual.toStringAsFixed(1)}km",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    "Meta: ${volumeMetaStr}km",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Stack(
                              children: [
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: progressoReal.clamp(0.0, 1.0),
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF06B6D4),
                                      borderRadius: BorderRadius.circular(3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF06B6D4,
                                          ).withOpacity(0.3),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),

          // Seção QUEM SEGUIR DINÂMICA
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "QUEM SEGUIR",
                    style: TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: _isLoadingSugestoes
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF06B6D4),
                          ),
                        )
                      : _sugestoesDb.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhuma sugestão no momento.",
                            style: TextStyle(color: Colors.white38),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _sugestoesDb.length,
                          itemBuilder: (context, index) {
                            final usuarioApi = _sugestoesDb[index];
                            return SuggestUserCard(usuario: usuarioApi);
                          },
                        ),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "DESAFIOS EM ALTA",
                    style: TextStyle(
                      color: Color(0xFF06B6D4),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: _isLoadingDesafios
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF06B6D4),
                          ),
                        )
                      : _desafiosDb.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhum desafio no momento.",
                            style: TextStyle(color: Colors.white38),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _desafiosDb.length,
                          itemBuilder: (context, index) {
                            final desafio = _desafiosDb[index];
                            return TrendingChallengeCard(desafio: desafio);
                          },
                        ),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildTerritoryMapCard(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Text(
                "SOCIAL",
                style: TextStyle(
                  color: Color(0xFF06B6D4),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          // Feed Social Dinâmico
          if (_isLoadingFeed)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
                ),
              ),
            )
          else if (_feedDb.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                  child: Text(
                    "Nenhuma atividade recente. Seja o primeiro!",
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final postagem = _feedDb[index];
                  return FeedCard(post: postagem);
                }, childCount: _feedDb.length),
              ),
            ),

          if (!_isLoadingFeed && _feedDb.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: _isLoadingMore
                      ? const CircularProgressIndicator(
                          color: Color(0xFF06B6D4),
                        )
                      : _hasMore
                      ? OutlinedButton(
                          onPressed: () => _fetchFeed(isRefresh: false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF06B6D4),
                            side: const BorderSide(color: Color(0xFF06B6D4)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text("CARREGAR MAIS POSTS"),
                        )
                      : const Text(
                          "Você chegou ao fim do FitFeed! 🏁",
                          style: TextStyle(color: Colors.white38),
                        ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildTerritoryMapCard() {
    return Container();
  }
}
