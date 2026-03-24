import 'package:fitlab_mobile2/widgets/feed_level_radial.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/feed_card.dart';
import '../models/feed_item.dart';
import '../widgets/suggest_user_card.dart';
import '../widgets/trending_challenge_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> sugestoes = [
      "Rodrigo Silva",
      "Mariana Luz",
      "Marcos Treino",
      "Julia Running",
      "Enzo Fit",
    ];
    // dados mockados para o feed (será substituído por dados reais da API no futuro)
    final List<FeedItem> mockFeed = [
      FeedItem(
        id: 1,
        type: FeedType.territory,
        userName: "Carlos Alves",
        userAvatar: "CA",
        timestamp: "10min atrás",
        title: "Dominou 3 novos territórios!",
        description: "Parque Ibirapuera, Vila Madalena e Pinheiros",
        stats: {"Territórios": "3", "Distância": "8.5 km"},
        likes: 6,
        comments: 7,
      ),
      FeedItem(
        id: 2,
        type: FeedType.achievement,
        userName: "Bruna Pires",
        userAvatar: "BP",
        timestamp: "4h atrás",
        title: "Mestre Jedi Desbloqueado!",
        description: "Completou a Missão: O Caminho do Jedi",
        badge: {"name": "Mestre Jedi", "icon": "🏅"},
        likes: 67,
        comments: 12,
      ),
    ];

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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Tooltip(
                  message: "Medidor de sequência",
                  triggerMode: TooltipTriggerMode.tap,
                  child: Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final streak = userProvider.usuarioLogado?.streak ?? 0;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          // Se o streak for 0, fundo cinza, senão, laranja
                          color: streak > 0
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              // Se o fogo estiver apagado (streak 0), mudamos a cor para cinza
                              color: streak > 0
                                  ? Colors.orange
                                  : Colors.white38,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "$streak",
                              style: TextStyle(
                                color: streak > 0
                                    ? Colors.white
                                    : Colors.white38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
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

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: FeedLevelRadial(),
            ),
          ),

          SliverToBoxAdapter(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final experimento = userProvider.usuarioLogado?.experimento;

                if (experimento == null) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: const Text(
                      "Nenhum experimento ativo. Vá ao laboratório!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white24, fontSize: 12),
                    ),
                  );
                }

                final String volumeMeta = experimento['volume'] ?? "0";
                final String dias = experimento['frequencia'] ?? "0";
                final double progressoReal = experimento['progresso'] ?? 0.0;

                double kmMetaNumerico =
                    double.tryParse(
                      volumeMeta.replaceAll(RegExp(r'[^0-9.]'), ''),
                    ) ??
                    0.0;
                double kmAtual = kmMetaNumerico * progressoReal;

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
                            "$dias restantes",
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
                              "Meta: ${volumeMeta}km",
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
                            widthFactor:
                                progressoReal, 
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

          //Seção QUEM SEGUIR
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
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sugestoes.length,
                    itemBuilder: (context, index) {
                      return SuggestUserCard(nome: sugestoes[index]);
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
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: const [
                      TrendingChallengeCard(
                        title: "Maratona Jedi",
                        category: "Resistência",
                        xp: "500",
                        icon: Icons.bolt,
                      ),
                      TrendingChallengeCard(
                        title: "Sprint Noturno",
                        category: "Velocidade",
                        xp: "350",
                        icon: Icons.nightlight_round,
                      ),
                      TrendingChallengeCard(
                        title: "Conquistador",
                        category: "Território",
                        xp: "800",
                        icon: Icons.map,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Espaçamento para o conteúdo não colar na barra
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Card de Mapa (Dominação Territorial)
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

          // Listagem do Feed
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => FeedCard(item: mockFeed[index]),
                childCount: mockFeed.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // widget de mapa 
  Widget _buildTerritoryMapCard() {
    return Container();
  }
}
