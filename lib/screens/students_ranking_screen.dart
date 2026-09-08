import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:fitlab_mobile2/providers/user_provider.dart';
import 'package:fitlab_mobile2/config/api_constants.dart';

class StudentsRankingScreen extends StatefulWidget {
  const StudentsRankingScreen({super.key});

  @override
  State<StudentsRankingScreen> createState() => _StudentsRankingScreenState();
}

class _StudentsRankingScreenState extends State<StudentsRankingScreen> {
  int _activeTimeFilter = 0; // 0: Mês, 1: Semana, 2: Geral
  bool _isLoading = true;
  List<dynamic> _rankingList = [];

  // Paleta de cores para os avatares ficarem bonitos
  final List<Color> _avatarColors = [
    Colors.greenAccent,
    const Color(0xFF06B6D4),
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.yellowAccent,
  ];

  // 👇 MÉTODO AUXILIAR PARA PEGAR O HEADER COM TOKEN 👇
  Map<String, String> _getAuthHeaders() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  void initState() {
    super.initState();
    _fetchRanking();
  }

  Future<void> _fetchRanking() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idCoach = userProvider.usuarioLogado?.id;
    if (idCoach == null) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}/gamificacao/treinador/$idCoach/ranking-alunos/completo');
      
      // 👇 INJETANDO TOKEN AQUI 👇
      final response = await http.get(url, headers: _getAuthHeaders());

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _rankingList = json.decode(utf8.decode(response.bodyBytes));
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Erro ao carregar ranking completo: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "RANKING DE PERFORMANCE",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTimeFilters(),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
                : RefreshIndicator(
                    color: const Color(0xFF06B6D4),
                    backgroundColor: const Color(0xFF1A1A1A),
                    onRefresh: _fetchRanking,
                    child: _buildFullRankingList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilters() {
    final filters = ["MÊS ATUAL", "ESTA SEMANA", "HISTÓRICO GERAL"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(filters.length, (index) {
          bool isSelected = _activeTimeFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              onSelected: (val) {
                setState(() => _activeTimeFilter = index);
                // No futuro: Você pode chamar _fetchRanking() aqui passando o filtro para a API!
              },
              selectedColor: const Color(0xFF06B6D4),
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.white10,
              ),
              showCheckmark: false,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFullRankingList() {
    if (_rankingList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.02)),
            ),
            child: const Column(
              children: [
                Icon(Icons.emoji_events_outlined, color: Colors.white24, size: 48),
                SizedBox(height: 16),
                Text(
                  "Nenhum aluno no ranking ainda.",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          )
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _rankingList.length,
      itemBuilder: (context, index) {
        final student = _rankingList[index];
        final pos = index + 1;
        final nomeAluno = student['nome'] ?? "Atleta";
        final totalTreinos = student['totalTreinos'] ?? 0;
        
        // Pega a primeira letra do nome de forma segura
        final primeiraLetra = nomeAluno.toString().trim().isNotEmpty 
            ? nomeAluno.toString().trim()[0].toUpperCase() 
            : "A";

        // Define uma cor fixa baseada no index para o avatar não ficar mudando de cor sozinho
        final color = _avatarColors[index % _avatarColors.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: pos <= 3
                  ? const Color(0xFF06B6D4).withOpacity(0.1)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              _buildPositionBadge(pos),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.1),
                child: Text(
                  primeiraLetra,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeAluno,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$totalTreinos treinos realizados",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Futuramente você pode exibir KM reais aqui quando o backend fornecer
              const Icon(Icons.chevron_right, color: Colors.white10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPositionBadge(int pos) {
    if (pos <= 3) {
      return Icon(
        Icons.workspace_premium_rounded,
        color: pos == 1
            ? Colors.amber
            : (pos == 2 ? Colors.grey[400] : Colors.brown[300]),
        size: 24,
      );
    }
    return SizedBox(
      width: 24,
      child: Text(
        "$posº",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}