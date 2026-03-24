import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../models/badge_model.dart';
import '../providers/user_provider.dart';
import '../widgets/badge_item.dart';
import '../widgets/profile_level_card.dart';
import '../widgets/radar_chart_interactive.dart';
import 'about_screen.dart';
import 'badges_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "LOGOUT",
            style: TextStyle(
              color: Color(0xFF06B6D4),
              letterSpacing: 2,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Deseja realmente sair da sua conta?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            // Botão NÃO -> Apenas fecha o diálogo e continua no perfil
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("NÃO", style: TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                "SIM, SAIR",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabeçalho do perfil
            _buildProfileHeader(),

            const SizedBox(height: 30),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ProfileLevelCard(),
            ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildBadgesGallery(context),
            ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "BIOMETRIA DE PERFORMANCE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Icon(
                          Icons.psychology,
                          color: Colors.white24,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // O Gráfico propriamente dito
                    // Dentro do Column da ProfileScreen
                    ValueListenableBuilder(
                      valueListenable: AppData.perfilAtleta,
                      builder: (context, perfil, child) {
                        return Center(
                          // Certifique-se de que está centralizado
                          child: RadarChartInteractive(
                            // Chame o widget direto, sem SizedBox restritivo
                            data: perfil.normalizedData,
                            color: const Color(0xFF06B6D4), // Ciano FitLab
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // menu de opções
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuTile(Icons.person_outline, "Editar Perfil", () {}),
                  _buildMenuTile(Icons.history, "Histórico de Corridas", () {}),
                  _buildMenuTile(
                    Icons.notifications_none,
                    "Notificações",
                    () {},
                  ),
                  _buildMenuTile(Icons.security, "Privacidade", () {}),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Colors.white10),
                  ),

                  // BOTÃO SOBRE
                  _buildMenuTile(Icons.info_outline, "Sobre o Projeto", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  }, isHighlight: true),

                  const SizedBox(height: 20),

                  // Botão de sair
                  _buildMenuTile(
                    Icons.logout,
                    "Sair",
                    () =>
                        _showLogoutDialog(context), // Chama a função do diálogo
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    // usamos o Consumer p/ ouvir as mudanças no UserProvider
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 60, bottom: 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1D4ED8), Color(0xFF0D0D0D)],
            ),
          ),
          child: Column(
            children: [
              // Avatar com borda neon
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
                  ),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF1A1A1A),
                  child: Icon(Icons.person, size: 50, color: Colors.white24),
                ),
              ),
              const SizedBox(height: 16),

              // NOME VINDO DO PROVIDER
              Text(
                userProvider.nome.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              ValueListenableBuilder(
                valueListenable: AppData.perfilAtleta,
                builder: (context, perfil, child) {
                  return Column(
                    children: [
                      Text(
                        perfil.classeIdentificada,
                        style: const TextStyle(
                          color: Color(0xFF06B6D4),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Baseado em ${perfil.totalCorridas} experimentos",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildQuickStatsGrid(),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color color = Colors.white70,
    bool isHighlight = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isHighlight ? const Color(0xFF06B6D4) : color),
      title: Text(
        title,
        style: TextStyle(
          color: isHighlight ? const Color(0xFF06B6D4) : color,
          fontSize: 16,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildQuickStatsGrid() {
    return ValueListenableBuilder(
      valueListenable: AppData.perfilAtleta,
      builder: (context, perfil, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            children: [
              _buildStatCard(Icons.map_outlined, "12", "Territórios"),
              _buildStatCard(Icons.emoji_events_outlined, "28", "Conquistas"),
              _buildStatCard(
                Icons.local_fire_department_outlined,
                "15",
                "Streak",
              ),
              _buildStatCard(Icons.track_changes_outlined, "#3", "Ranking"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGallery(BuildContext context) {
    final displayBadges = AppData.allBadges.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "CONQUISTAS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BadgesScreen(
                        allBadges: AppData.allBadges,
                      ), // Passa a lista completa
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "Ver mais",
                  style: TextStyle(color: Color(0xFF06B6D4), fontSize: 12),
                ),
              ),
            ],
          ),

          const Text(
            "Veja as conquistas que você desbloqueou",
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),

          const SizedBox(height: 16),

          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: displayBadges.length,
            itemBuilder: (context, index) {
              return BadgeItem(badge: displayBadges[index], context: context);
            }
          ),
        ],
      ),
    );
  }
}
