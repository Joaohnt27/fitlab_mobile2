import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/subscription_screen.dart';
import 'all_challenges_screen.dart';
import '../widgets/challenge_card.dart';
import '../widgets/lab_goals_card.dart';
import '../widgets/fitlab_ai_card.dart';
import '../widgets/ai_training_result_card.dart';
import '../widgets/coach_dashboard.dart';
import '../config/api_constants.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  bool _hasGeneratedAIWorkout = false;
  Map<String, dynamic> aiRequestData = {"goal": "", "timeframe": ""};

  Map<String, dynamic>? _experimentoAtivo;
  bool _isLoadingExperimento = true;

  @override
  void initState() {
    super.initState();
    _fetchExperimentoAtivo();
  }

  // 👇 BUSCA O EXPERIMENTO ATIVO DO BANCO DE DADOS 👇
  Future<void> _fetchExperimentoAtivo() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/usuarios/$idUsuario/experimentos/ativo',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        setState(() {
          _experimentoAtivo = json.decode(utf8.decode(response.bodyBytes));
          _isLoadingExperimento = false;
        });
      } else {
        setState(() {
          _experimentoAtivo = null;
          _isLoadingExperimento = false;
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar experimento ativo: $e");
      setState(() => _isLoadingExperimento = false);
    }
  }

  // 👇 DELETA (CANCELA) O EXPERIMENTO ATUAL 👇
  Future<void> _abortarExperimento() async {
    if (_experimentoAtivo == null) return;

    final idExperimento = _experimentoAtivo!['id'];
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/usuarios/$idUsuario/experimentos/$idExperimento',
    );

    setState(() => _isLoadingExperimento = true);

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Experimento abortado com sucesso."),
            backgroundColor: Colors.redAccent,
          ),
        );
        _fetchExperimentoAtivo(); // Recarrega a tela para mostrar o formulário novamente
      }
    } catch (e) {
      debugPrint("Erro ao abortar experimento: $e");
      setState(() => _isLoadingExperimento = false);
    }
  }

  Future<List<dynamic>> _fetchDesafiosAtivos(int idUsuario) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/usuarios/$idUsuario/desafios',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        throw Exception('Falha ao carregar desafios');
      }
    } catch (e) {
      debugPrint("Erro ao buscar desafios ativos: $e");
      return [];
    }
  }

  void _iniciarExperimento(String volume, String frequencia) async {
    setState(() => _isLoadingExperimento = true);

    // Aguarda a resposta verdadeira do Provider
    bool sucesso = await context.read<UserProvider>().salvarExperimentoUsuario(
      context,
      volume,
      frequencia,
    );

    if (sucesso) {
      // Só comemora se o Java salvou de verdade no banco
      _showCustomDialog(
        "FÓRMULA PRONTA!",
        "Seu experimento de $volume configurado.",
      );
      _fetchExperimentoAtivo();
    } else {
      // Se falhou, tira o loading para o usuário poder tentar de novo
      setState(() => _isLoadingExperimento = false);
    }
  }

  void _aoGerarTreinoIA(Map<String, dynamic> data) async {
    // 1. Abre um modal de Loading que o usuário não consegue fechar sozinho
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(color: Color(0xFF06B6D4)),
                SizedBox(height: 24),
                Text(
                  "SINTETIZANDO FÓRMULA...",
                  style: TextStyle(
                    color: Color(0xFF06B6D4),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "O Cérebro FitLab está calculando sua biometria. Isso pode levar alguns minutos.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );

    final url = Uri.parse('${ApiConstants.baseUrl}/ia/gerar-treino');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final usuario = userProvider.usuarioLogado;

    final payload = {
      "usuario_id": usuario?.id,
      "meta": data["meta"],
      "prazo": data["prazo"],
      "peso_kg": data["peso_kg"],
      "altura_cm": data["altura_cm"],
      "nivel_experiencia": data["nivel_experiencia"],
      "contexto_adicional": data["contexto_adicional"],
      "dt_nascimento": usuario?.dtNascimento ?? "Não informada",
      "historico_app":
          "Atleta com ${usuario?.totalTreinos ?? 0} treinos no app e streak atual de ${usuario?.streak ?? 0} dias.",
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(payload),
      );

      // 2. Fecha o Loading animado assim que a resposta chega
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final treinoInteligente = json.decode(utf8.decode(response.bodyBytes));

        treinoInteligente['inputs_usuario'] = {
          "peso": data["peso_kg"],
          "altura": data["altura_cm"],
          "nivel": data["nivel_experiencia"],
          "meta": data["meta"],
        };

        setState(() {
          aiRequestData = treinoInteligente;
          _hasGeneratedAIWorkout = true;
        });
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Falha ao gerar o treino. Tente novamente."),
              backgroundColor: Colors.redAccent.withOpacity(0.8),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted)
        Navigator.pop(context); // Fecha o loading se der erro
      debugPrint("Erro de conexão na IA: $e");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("O Cérebro FitLab está offline no momento."),
            backgroundColor: Colors.redAccent.withOpacity(0.8),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final usuario = userProvider.usuarioLogado;

    final bool isTreinador = usuario?.role == 'Treinador';
    final bool isPremium =
        usuario?.plano != null &&
        usuario!.plano != 'Free' &&
        usuario.plano != '';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(usuario?.streak ?? 0),
          const SliverToBoxAdapter(child: _PageIntroText()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isTreinador) ...[
                    const CoachDashboard(),
                  ] else ...[
                    const _SectionHeader(
                      title: "Cérebro FitLab",
                      subtitle: "Inteligência Artificial",
                    ),
                    const SizedBox(height: 16),
                    _hasGeneratedAIWorkout
                        ? AITrainingResultCard(
                            data: aiRequestData,
                            onStart: () => debugPrint("Iniciando GPS..."),
                          )
                        : FitLabAICard(onGenerate: _aoGerarTreinoIA),
                    const SizedBox(height: 32),
                    const _SectionHeader(title: "Configurar Experimento"),
                    const SizedBox(height: 16),

                    // 👇 RENDERIZAÇÃO DINÂMICA DO EXPERIMENTO 👇
                    if (_isLoadingExperimento)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF06B6D4),
                        ),
                      )
                    else if (_experimentoAtivo != null)
                      _buildActiveExperimentCard()
                    else
                      LabGoalsCard(onIniciar: _iniciarExperimento),
                  ],

                  const SizedBox(height: 32),
                  _SectionHeader(
                    title: "Desafios Ativos",
                    onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllChallengesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  FutureBuilder<List<dynamic>>(
                    future: _fetchDesafiosAtivos(usuario?.id ?? 1),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF06B6D4),
                            ),
                          ),
                        );
                      }

                      final activeChallenges = snapshot.data ?? [];

                      if (activeChallenges.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Nenhum desafio ativo.\nExplore o Lab para aceitar novos desafios!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white38),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: activeChallenges
                            .take(3)
                            .map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ChallengeCard(
                                  challenge: c as Map<String, dynamic>,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),

                  if (!isTreinador) ...[
                    const SizedBox(height: 32),
                    const _SectionHeader(title: "Plano Semanal"),
                    const SizedBox(height: 16),
                    _buildWeeklyPlanWithAccessControl(isPremium),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveExperimentCard() {
    final volume = _experimentoAtivo!['volume'] ?? "N/A";

    // 👇 Calcula dinamicamente os dias restantes usando a dataFim vinda do back-end
    String diasRestantesStr = "N/A";
    if (_experimentoAtivo!['dataFim'] != null) {
      try {
        DateTime dataFim = DateTime.parse(_experimentoAtivo!['dataFim']);
        int dias = dataFim.difference(DateTime.now()).inDays;
        diasRestantesStr = "${dias > 0 ? dias : 0} dias";
      } catch (e) {
        diasRestantesStr = _experimentoAtivo!['frequencia'] ?? "N/A";
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.science, color: Color(0xFF06B6D4)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "EM ANDAMENTO",
                      style: TextStyle(
                        color: Color(0xFF06B6D4),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      "Experimento Atual",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildExperimentData("Volume Meta", "$volume km"),
              _buildExperimentData("Tempo Restante", diasRestantesStr),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _abortarExperimento,
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "ABORTAR EXPERIMENTO",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperimentData(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyPlanWithAccessControl(bool isPremium) {
    if (isPremium) return const _TrainingPlanPlaceholder();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.1,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const _TrainingPlanPlaceholder(),
            ),
          ),
          _buildLockOverlay(),
        ],
      ),
    );
  }

  Widget _buildLockOverlay() {
    return Column(
      children: [
        const Icon(Icons.lock_outline, color: Color(0xFF06B6D4), size: 28),
        const SizedBox(height: 12),
        const Text(
          "ACESSO RESTRITO",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        const Text(
          "Disponível apenas para membros Pro e Elite",
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
          ),
          child: const Text(
            "FAZER UPGRADE",
            style: TextStyle(
              color: Color(0xFF06B6D4),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(int streak) {
    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A1A),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          "LABORATÓRIO",
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
          child: const Center(
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.science_outlined,
                size: 120,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      actions: [_StreakIndicator(streak: streak)],
    );
  }

  void _showCustomDialog(String title, String content, {bool isAI = false}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAI ? Icons.psychology : Icons.science,
                color: const Color(0xFF06B6D4),
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "VAMOS NESSA!",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;
  const _SectionHeader({required this.title, this.subtitle, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
          ],
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text(
              "VER TODOS",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class _StreakIndicator extends StatelessWidget {
  final int streak;
  const _StreakIndicator({required this.streak});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: streak > 0 ? Colors.orange.withOpacity(0.2) : Colors.white10,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: streak > 0 ? Colors.orange : Colors.white38,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                "$streak",
                style: TextStyle(
                  color: streak > 0 ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIntroText extends StatelessWidget {
  const _PageIntroText();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 20, left: 24, right: 24),
      child: Text(
        "Seu centro de treinamento e desafios",
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }
}

class _TrainingPlanPlaceholder extends StatelessWidget {
  const _TrainingPlanPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const Center(
        child: Text(
          "Plano Semanal Carregado",
          style: TextStyle(color: Colors.white38),
        ),
      ),
    );
  }
}
