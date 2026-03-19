import 'package:flutter/material.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

                  // BOTÃO SOBRE (Requisito RF004)
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
                  _buildMenuTile(Icons.logout, "Sair", () {
                    Navigator.pushReplacementNamed(context, '/login');
                  }, color: Colors.redAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
          const Text(
            "JOÃO FRAGAEL UA",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const Text(
            "Nível 67 • Corredor Jedi",
            style: TextStyle(
              color: Color(0xFF06B6D4),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
