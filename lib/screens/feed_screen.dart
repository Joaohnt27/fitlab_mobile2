import 'package:flutter/material.dart';
import '../widgets/feed_card.dart';
import '../models/feed_item.dart';
import '../widgets/suggest_user_card.dart';

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
              // Medidor de sequência (Streak) com tooltip
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Tooltip(
                  message: "Medidor de sequência",
                  triggerMode: TooltipTriggerMode.tap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "7",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),

          // --- SEÇÃO QUEM SEGUIR ---
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

  // O seu widget de mapa (mesmo código anterior)
  Widget _buildTerritoryMapCard() {
    return Container(/* ... mesmo código do card anterior ... */);
  }
}
