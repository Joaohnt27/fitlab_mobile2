import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/user_provider.dart';
import '../config/api_constants.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<dynamic> _badges = [];
  bool _isLoading = true;

  String _selectedRarity = 'Todas';
  bool _showOnlyUnlocked = false;

  final List<String> _rarities = [
    'Todas',
    'COMMON',
    'RARE',
    'EPIC',
    'LEGENDARY',
  ];

  @override
  void initState() {
    super.initState();
    _fetchBadges();
  }

  Future<void> _fetchBadges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;
    final url = Uri.parse('${ApiConstants.baseUrl}/usuarios/$idUsuario/badges');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _badges = json.decode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Erro ao buscar badges: $e");
      setState(() => _isLoading = false);
    }
  }

  // 👇 NOVA FUNÇÃO: Tradutor de Raridade
  String _traduzirRaridade(String raridade) {
    switch (raridade.toUpperCase()) {
      case 'COMMON':
        return 'Comum';
      case 'RARE':
        return 'Rara';
      case 'EPIC':
        return 'Épica';
      case 'LEGENDARY':
        return 'Lendária';
      case 'TODAS':
        return 'Todas';
      default:
        return raridade;
    }
  }

  List<dynamic> get _processedBadges {
    var filtered = _badges.where((b) {
      final rarity = (b['rarity'] ?? '').toString().toUpperCase();
      final isUnlocked = b['unlocked'] == true;

      if (_selectedRarity != 'Todas' && rarity != _selectedRarity) {
        return false;
      }
      if (_showOnlyUnlocked && !isUnlocked) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      final aUnlocked = a['unlocked'] == true ? 1 : 0;
      final bUnlocked = b['unlocked'] == true ? 1 : 0;
      return bUnlocked.compareTo(aUnlocked);
    });

    return filtered;
  }

  void _showBadgeDetails(BuildContext context, Map<String, dynamic> badge) {
    final nome = badge['name'] ?? 'Insígnia Misteriosa';
    final icone = badge['icon'] ?? '🏅';
    // 👇 Usa o tradutor aqui!
    final raridade = _traduzirRaridade(
      (badge['rarity'] ?? 'COMMON').toString(),
    ).toUpperCase();
    final requisito = badge['requisito'] ?? 'Requisito desconhecido.';
    final isUnlocked = badge['unlocked'] == true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked
                        ? const Color(0xFF06B6D4)
                        : Colors.white10,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Opacity(
                    opacity: isUnlocked ? 1.0 : 0.3,
                    child: Text(icone, style: const TextStyle(fontSize: 40)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                nome.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                raridade, // Vai aparecer "COMUM", "RARA", etc.
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                requisito,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              if (!isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, color: Colors.white54, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Bloqueado: Continue treinando!",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Desbloqueado!",
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "FECHAR",
                  style: TextStyle(color: Color(0xFF06B6D4)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 👇 NOVA BARRA DE FILTROS: Visual personalizado e moderno
  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Pílula customizada para "Desbloqueadas"
          GestureDetector(
            onTap: () => setState(() => _showOnlyUnlocked = !_showOnlyUnlocked),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _showOnlyUnlocked
                    ? const Color(0xFF06B6D4).withOpacity(0.15)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _showOnlyUnlocked
                      ? const Color(0xFF06B6D4)
                      : Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _showOnlyUnlocked ? Icons.check_circle : Icons.lock_open,
                    color: _showOnlyUnlocked
                        ? const Color(0xFF06B6D4)
                        : Colors.white54,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Desbloqueadas",
                    style: TextStyle(
                      color: _showOnlyUnlocked
                          ? const Color(0xFF06B6D4)
                          : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Pílula customizada com Menu Suspenso para "Raridade"
          PopupMenuButton<String>(
            onSelected: (val) => setState(() => _selectedRarity = val),
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            position: PopupMenuPosition.under,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedRarity == 'Todas'
                        ? "Raridade"
                        : _traduzirRaridade(
                            _selectedRarity,
                          ), // Exibe traduzido no botão
                    style: TextStyle(
                      color: _selectedRarity != 'Todas'
                          ? const Color(0xFF06B6D4)
                          : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white54,
                    size: 16,
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => _rarities.map((r) {
              return PopupMenuItem(
                value: r,
                child: Text(
                  _traduzirRaridade(r), // Exibe traduzido na lista
                  style: TextStyle(
                    color: _selectedRarity == r
                        ? const Color(0xFF06B6D4)
                        : Colors.white,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayBadges = _processedBadges;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "MINHAS CONQUISTAS",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterBar(),
                Expanded(
                  child: displayBadges.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhuma conquista encontrada com estes filtros.",
                            style: TextStyle(color: Colors.white38),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 15,
                                childAspectRatio: 0.8,
                              ),
                          itemCount: displayBadges.length,
                          itemBuilder: (context, index) {
                            final badge = displayBadges[index];
                            final nome = badge['name'] ?? 'Insígnia';
                            final icone = badge['icon'] ?? '🏅';
                            final isUnlocked = badge['unlocked'] == true;

                            return GestureDetector(
                              onTap: () => _showBadgeDetails(context, badge),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E1E1E),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isUnlocked
                                                ? const Color(
                                                    0xFF06B6D4,
                                                  ).withOpacity(0.5)
                                                : Colors.white10,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Opacity(
                                            opacity: isUnlocked ? 1.0 : 0.3,
                                            child: Text(
                                              icone,
                                              style: const TextStyle(
                                                fontSize: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (!isUnlocked)
                                        const Icon(
                                          Icons.lock,
                                          color: Colors.white54,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    nome,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isUnlocked
                                          ? Colors.white
                                          : Colors.white38,
                                      fontSize: 10,
                                      fontWeight: isUnlocked
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
