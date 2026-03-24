import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_data.dart';
import '../models/user_model.dart'; 
import '../providers/user_provider.dart';
import '../widgets/badge_item.dart';
import '../widgets/profile_level_card.dart';
import '../widgets/radar_chart_interactive.dart';
import 'about_screen.dart';
import 'badges_screen.dart';
import 'edit_profile_screen.dart';

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
      body: Consumer<UserProvider>(
        // Consumer no topo para reagir a XP, Streak, etc.
        builder: (context, userProvider, child) {
          final usuario = userProvider.usuarioLogado;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(usuario), // Passa o usuário para o header

                const SizedBox(height: 30),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child:
                      ProfileLevelCard(), // Verifique se há um Consumer dentro deste widget também
                ),

                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildBadgesGallery(context),
                ),

                const SizedBox(height: 32),

                _buildBiometriaCard(context),

                const SizedBox(height: 32),

                _buildMenuOptions(context),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? usuario) {
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
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF1A1A1A),
              child: Text(
                usuario?.avatar ?? "🧪",
                style: const TextStyle(fontSize: 50),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            (usuario?.nome ?? "ATLETA").toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          if (usuario?.bio != null && usuario!.bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: Text(
                usuario.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 10),
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
                  Text(
                    "Baseado em ${perfil.totalCorridas} experimentos",
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  const SizedBox(height: 30),
                  _buildQuickStatsGrid(
                    usuario,
                  ), // Passa o usuário dinâmico aqui
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(UserModel? usuario) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildStatCard(
              Icons.map_outlined,
              "${usuario?.territorios ?? 0}",
              "Territórios",
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              Icons.emoji_events_outlined,
              "${usuario?.conquistas ?? 0}",
              "Conquistas",
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              Icons.local_fire_department_outlined,
              "${usuario?.streak ?? 0}",
              "Streak",
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              Icons.track_changes_outlined,
              usuario?.ranking != null && usuario?.ranking != 0
                  ? "#${usuario!.ranking}"
                  : "#--",
              "Ranking",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometriaCard(BuildContext context) {
    return Padding(
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "BIOMETRIA DE PERFORMANCE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Icon(Icons.psychology, color: Colors.white24, size: 20),
              ],
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder(
              valueListenable: AppData.perfilAtleta,
              builder: (context, perfil, child) {
                return Center(
                  child: RadarChartInteractive(
                    data: perfil.normalizedData,
                    color: const Color(0xFF06B6D4),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuTile(Icons.person_outline, "Editar Perfil", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          }),
          _buildMenuTile(Icons.history, "Histórico de Corridas", () {}),
          _buildMenuTile(Icons.notifications_none, "Notificações", () {}),
          _buildMenuTile(Icons.security, "Privacidade", () {}),
          const Divider(color: Colors.white10, height: 32),
          _buildMenuTile(Icons.info_outline, "Sobre o Projeto", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          }, isHighlight: true),
          const SizedBox(height: 10),
          _buildMenuTile(
            Icons.logout,
            "Sair",
            () => _showLogoutDialog(context),
            color: Colors.redAccent,
          ),
        ],
      ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      builder: (context) =>
                          BadgesScreen(allBadges: AppData.allBadges),
                    ),
                  );
                },
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
            },
          ),
        ],
      ),
    );
  }
}
