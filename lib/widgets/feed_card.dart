import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert'; 
import '../providers/user_provider.dart';
import '../widgets/comments_sheet.dart';

class FeedCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const FeedCard({super.key, required this.post});

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  bool _isLiked = false;
  late int _likesCount;
  bool _isLoadingLike = false;

  @override
  void initState() {
    super.initState();
    // Inicializa a contagem de likes baseada no que veio do banco
    _likesCount = widget.post['likes'] ?? 0;

    _isLiked = widget.post['curtidoPorMim'] ?? false;
  }

  Future<void> _toggleLike() async {
    if (_isLoadingLike) return; // Evita duplo clique rápido

    setState(() => _isLoadingLike = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;
    final idPost = widget.post['id'];

    final url = Uri.parse(
      'http://127.0.0.1:8080/api/feed/postagens/$idPost/curtir/$idUsuario',
    );

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        setState(() {
          // A API devolve essas strings exatas no FeedController
          if (response.body == "Postagem curtida") {
            _isLiked = true;
            _likesCount++;
          } else {
            _isLiked = false;
            _likesCount--;
          }
        });
      }
    } catch (e) {
      debugPrint("Erro ao curtir post: $e");
    } finally {
      setState(() => _isLoadingLike = false);
    }
  }

  void _abrirModalComentarios() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(
            context,
          ).viewInsets.bottom, 
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6, // Ocupa 60% da tela
          child: CommentsSheet(
            idPost: widget.post['id'] ?? 0,
            onComentarioAdicionado: () {
              // Atualiza o contador de comentários na tela instantaneamente
              setState(() {
                widget.post['comentarios'] =
                    (int.parse(widget.post['comentarios']?.toString() ?? '0') +
                            1)
                        .toString();
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nome = widget.post['nomeUsuario'] ?? 'Atleta FitLab';
    final avatar =
        widget.post['avatarUsuario'] ?? (nome.isNotEmpty ? nome[0] : 'F');
    final tipo = widget.post['tipoPost'] ?? 'TEXTO';
    final titulo = widget.post['titulo'] ?? '';
    final texto = widget.post['texto'];
    final comentarios = widget.post['comentarios']?.toString() ?? '0';

    String dataFormatada = 'Recentemente';
    if (widget.post['dataHora'] != null) {
      try {
        final dt = DateTime.parse(widget.post['dataHora']);
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

          if (tipo == 'CONQUISTA') _buildBadgeAward(titulo),
          if (tipo == 'TERRITORIO') _buildStatsRow(),

          // Like e Comentário
          const Divider(color: Colors.white10, height: 32),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                // Botão de Curtir Interativo
                _buildInteractiveActionButton(
                  icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                  count: _likesCount.toString(),
                  isActive: _isLiked,
                  onTap: _toggleLike,
                ),
                const SizedBox(width: 24),
                // Botão de Comentário Interativo
                _buildInteractiveActionButton(
                  icon: Icons.chat_bubble_outline,
                  count: comentarios,
                  isActive: false,
                  onTap: _abrirModalComentarios, 
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color color;
    if (type == 'TERRITORIO') {
      color = Colors.cyan;
    } else if (type == 'CONQUISTA') {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

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

  Widget _buildInteractiveActionButton({
    required IconData icon,
    required String count,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? const Color(0xFF06B6D4) : Colors.white38;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              count,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}