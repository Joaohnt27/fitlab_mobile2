import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Header Estilo Workout
            _buildSliverHeader(),

            // 2. Campo de Busca
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: _buildSearchBar(),
              ),
            ),

            // 3. Card "Minha Posição"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: _buildMyRankCard(context),
              ),
            ),

            // 4. TabBar Fixa (Sticky)
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

            // 5. Conteúdo das Abas
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

  // --- COMPONENTES DE INTERFACE ---

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
                label: "TERRITÓRIOS",
                value: "${user?.territorios ?? 0}",
              ),
              _StatColumn(label: "DEFESAS", value: "8"),
            ],
          ),
        ],
      ),
    );
  }

  // --- CONTEÚDO DAS ABAS ---

  Widget _buildGlobalTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 8,
      itemBuilder: (context, index) =>
          _RankingTile(index: index, name: "Atleta Lab Global"),
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
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {}, // Lógica para adicionar amigos
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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1D4ED8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1D4ED8).withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFF06B6D4), size: 20),
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
        _RankingTile(
          index: 0,
          name: "Prof. Ricardo Silva",
          isTrainer: true,
          specialty: "Maratona & Corrida de Rua",
          rating: 4.8,
          students: 120,
        ),
        _RankingTile(
          index: 1,
          name: "Coach Marina Luz",
          isTrainer: true,
          specialty: "HIIT & Performance Muscular",
          rating: 4.9,
          students: 200,
        ),
        _RankingTile(
          index: 2,
          name: "Dr. Paulo Mendes",
          isTrainer: true,
          specialty: "Reabilitação Esportiva",
          rating: 4.7,
          students: 80,
        ),
      ],
    );
  }
}

// --- WIDGETS DE APOIO ---

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
  final bool isTrainer;
  final String? specialty;
  final double rating; // Adicionado: 0.0 a 5.0
  final int students; // Adicionado: Qtd de alunos

  const _RankingTile({
    super.key,
    required this.index,
    required this.name,
    this.isTrainer = false,
    this.specialty,
    this.rating = 0.0,
    this.students = 0,
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

    // Lógica do Top 3 para Atletas
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
      onTap: isTrainer ? () => _mostrarPerfilTreinador(context) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alinha ao topo para caber mais info
          children: [
            if (!isTrainer) SizedBox(width: 30, child: Center(child: rankIcon)),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white10,
              child: Text(
                isTrainer ? "👨‍🏫" : "🧪",
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
                        : "Ribeirão Preto, SP",
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),

                  // Seção exclusiva para Treinadores: Estrelas e Alunos
                  if (isTrainer) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Estrelas
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
                        // Alunos
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
            const Icon(Icons.chevron_right, color: Colors.white10),
          ],
        ),
      ),
    );
  }

  void _mostrarPerfilTreinador(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A1A),
        content: Text(
          "Acessando perfil de especialista: $name",
          style: const TextStyle(color: Color(0xFF06B6D4)),
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
