import 'package:flutter/material.dart';

class FeedCard extends StatelessWidget {
  // Agora recebe o JSON dinâmico da API
  final Map<String, dynamic> post;

  const FeedCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // Extrai os dados do mapa com valores padrão de segurança
    final nome = post['nomeUsuario'] ?? 'Atleta FitLab';
    // Pega a primeira letra do nome para o Avatar, caso não tenha imagem
    final avatar = post['avatarUsuario'] ?? (nome.isNotEmpty ? nome[0] : 'F');
    final tipo = post['tipoPost'] ?? 'TEXTO';
    final titulo = post['titulo'] ?? '';
    final texto = post['texto'];
    final likes = post['likes']?.toString() ?? '0';
    final comentarios = post['comentarios']?.toString() ?? '0';

    // Formatação simples da data ISO que vem do Java
    String dataFormatada = 'Recentemente';
    if (post['dataHora'] != null) {
      try {
        final dt = DateTime.parse(post['dataHora']);
        dataFormatada =
            "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Nome + Badge de Tipo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF06B6D4),
                  child: Text(
                    avatar.length > 2
                        ? avatar.substring(0, 2).toUpperCase()
                        : avatar.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dataFormatada,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTypeBadge(tipo),
              ],
            ),
          ),

          // Conteúdo: Título e Descrição
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (titulo.isNotEmpty)
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (texto != null && texto.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    texto,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),

          // Exibe um card bônus baseado no TIPO de postagem
          if (tipo == 'CONQUISTA') _buildBadgeAward(titulo),
          if (tipo == 'TERRITORIO') _buildStatsRow(),

          // Actions: Like e Comentário
          const Divider(color: Colors.white10, height: 32),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                _buildActionButton(Icons.thumb_up_off_alt, likes),
                const SizedBox(width: 24),
                _buildActionButton(Icons.chat_bubble_outline, comentarios),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MÉTODOS AUXILIARES ADAPTADOS PARA STRINGS DO BANCO ---

  Widget _buildTypeBadge(String type) {
    Color color;
    if (type == 'TERRITORIO')
      color = Colors.cyan;
    else if (type == 'CONQUISTA')
      color = Colors.orange;
    else
      color = Colors.green; // TEXTO/TREINO normal

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(_getIcon(type), color: color, size: 16),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'TERRITORIO':
        return Icons.map_outlined;
      case 'CONQUISTA':
        return Icons.emoji_events_outlined;
      default:
        return Icons.directions_run;
    }
  }

  // Estatísticas mockadas para o TCC baseadas no evento "TERRITÓRIO"
  Widget _buildStatsRow() {
    final Map<String, String> stats = {"Territórios": "+3", "Bônus XP": "300"};
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8,
        children: stats.entries
            .map(
              (e) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${e.key}: ${e.value}",
                  style: const TextStyle(
                    color: Color(0xFF06B6D4),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // Badge especial baseada no título da Conquista
  Widget _buildBadgeAward(String titulo) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.2), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Text("🏅", style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "CONQUISTA DESBLOQUEADA",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 20),
        const SizedBox(width: 6),
        Text(
          count,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }
}
