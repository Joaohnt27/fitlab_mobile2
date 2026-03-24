import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _reminders = true;
  bool _achievements = true;
  bool _ranking = false;
  bool _marketing = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final prefs = userProvider.prefsNotificacoes;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "NOTIFICAÇÕES",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("ATIVIDADE E TREINO"),
            _buildNotificationTile(
              Icons.timer_outlined,
              "Lembretes de Treino",
              "Avisar quando for hora de iniciar o experimento do dia.",
              prefs['reminders'] ?? true, // Lendo do Provider
              (val) => userProvider.alternarNotificacao(
                'reminders',
                val,
              ), // Alterando no Provider
            ),
            const Divider(color: Colors.white10, height: 1),

            _buildSectionHeader("GAMIFICAÇÃO"),
            _buildNotificationTile(
              Icons.emoji_events_outlined,
              "Conquistas e Badges",
              "Notificar imediatamente ao desbloquear um novo badge.",
              prefs['achievements'] ?? true,
              (val) => userProvider.alternarNotificacao('achievements', val),
            ),
            _buildNotificationTile(
              Icons.leaderboard_outlined,
              "Alertas de Ranking",
              "Avisar se alguém te ultrapassar no ranking global.",
              prefs['ranking'] ?? false,
              (val) => userProvider.alternarNotificacao('ranking', val),
            ),

            _buildSectionHeader("COMUNICADOS"),
            _buildNotificationTile(
              Icons.campaign_outlined,
              "Novidades do Lab",
              "Receba atualizações sobre novas funcionalidades e eventos.",
              prefs['marketing'] ?? false,
              (val) => userProvider.alternarNotificacao('marketing', val),
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                "As notificações ajudam você a manter seu Streak ${prefs['reminders'] == true ? 'ativo' : 'inativo'}.",
                style: const TextStyle(color: Colors.white24, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF06B6D4),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          subtitle,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ),
      activeColor: const Color(0xFF06B6D4),
      activeTrackColor: const Color(0xFF06B6D4).withOpacity(0.2),
      inactiveTrackColor: Colors.white10,
      value: value,
      onChanged: onChanged,
    );
  }
}
