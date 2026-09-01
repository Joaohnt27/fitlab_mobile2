import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/user_provider.dart';
import '../config/api_constants.dart';

class ChallengeDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> desafio;

  const ChallengeDetailsScreen({super.key, required this.desafio});

  @override
  State<ChallengeDetailsScreen> createState() => _ChallengeDetailsScreenState();
}

class _ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
  bool _isLoadingAction = false;
  bool _isLoadingStatus = true;
  bool _aceito = false;
  bool _concluido = false;
  double _progressoReal = 0.0;
  double _totalReal = 1.0;

  @override
  void initState() {
    super.initState();
    _checkChallengeStatus();
  }

  Future<void> _checkChallengeStatus() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;
    final idDesafio = widget.desafio['id'];
    // Pega o nome exato da insígnia que este desafio dá
    final nomeBadgeExclusiva = widget.desafio['badgeExclusiva']
        ?.toString()
        .trim();

    try {
      // 1. Busca os Desafios Ativos
      final urlAtivos = Uri.parse(
        '${ApiConstants.baseUrl}/usuarios/$idUsuario/desafios',
      );
      final resAtivos = await http.get(urlAtivos);

      // 2. Busca as Insígnias do Usuário (O Pulo do Gato para saber se concluiu)
      final urlBadges = Uri.parse(
        '${ApiConstants.baseUrl}/usuarios/$idUsuario/badges',
      );
      final resBadges = await http.get(urlBadges);

      bool jaConcluiu = false;

      if (resBadges.statusCode == 200) {
        final List<dynamic> badges = json.decode(
          utf8.decode(resBadges.bodyBytes),
        );
        // Verifica se o usuário tem a insígnia que tenha o mesmo nome da recompensa deste desafio e está desbloqueada
        jaConcluiu = badges.any(
          (b) =>
              b['unlocked'] == true &&
              b['name'] != null &&
              b['name'].toString().trim() == nomeBadgeExclusiva,
        );
      }

      if (jaConcluiu) {
        // Se já tem a badge, trava tudo em 100% concluído!
        setState(() {
          _concluido = true;
          _aceito = true;
          _totalReal =
              (widget.desafio['total'] ?? widget.desafio['objetivoKm'] ?? 1)
                  .toDouble();
          _progressoReal = _totalReal;
          _isLoadingStatus = false;
        });
        return;
      }

      // Se não concluiu, verifica se está em andamento
      if (resAtivos.statusCode == 200) {
        final List<dynamic> desafiosAtivos = json.decode(
          utf8.decode(resAtivos.bodyBytes),
        );
        final desafioAtivo = desafiosAtivos.firstWhere(
          (d) =>
              d['id'] == idDesafio ||
              (d['desafio'] != null && d['desafio']['id'] == idDesafio),
          orElse: () => null,
        );

        setState(() {
          if (desafioAtivo != null) {
            _aceito = true;
            _progressoReal =
                (desafioAtivo['progressoAtual'] ??
                        desafioAtivo['progress'] ??
                        0)
                    .toDouble();
            _totalReal =
                (desafioAtivo['total'] ?? desafioAtivo['objetivoKm'] ?? 1)
                    .toDouble();
            _concluido = _progressoReal >= _totalReal && _totalReal > 0;
          } else {
            _aceito = false;
            _concluido = false;
            _totalReal =
                (widget.desafio['total'] ?? widget.desafio['objetivoKm'] ?? 1)
                    .toDouble();
          }
          _isLoadingStatus = false;
        });
      } else {
        setState(() => _isLoadingStatus = false);
      }
    } catch (e) {
      debugPrint("Erro ao checar status: $e");
      setState(() => _isLoadingStatus = false);
    }
  }

  Future<void> _aceitarDesafio(BuildContext context, int idDesafio) async {
    setState(() => _isLoadingAction = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/usuarios/$idUsuario/desafios/$idDesafio',
    );

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Desafio Aceito!"),
            backgroundColor: Colors.green,
          ),
        );
        await userProvider.recarregarUsuario();
        setState(() => _aceito = true);
      }
    } catch (e) {
      debugPrint("Erro ao aceitar: $e");
    } finally {
      setState(() => _isLoadingAction = false);
    }
  }

  Future<void> _cancelarDesafio(BuildContext context, int idDesafio) async {
    setState(() => _isLoadingAction = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final idUsuario = userProvider.usuarioLogado?.id ?? 1;
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/usuarios/$idUsuario/desafios/$idDesafio',
    );

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Desafio abandonado."),
            backgroundColor: Colors.redAccent,
          ),
        );
        await userProvider.recarregarUsuario();
        setState(() {
          _aceito = false;
          _progressoReal = 0.0;
        });
      }
    } catch (e) {
      debugPrint("Erro ao cancelar: $e");
    } finally {
      setState(() => _isLoadingAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.desafio['titulo'] ?? widget.desafio['title'] ?? 'Desafio';
    final descricao =
        widget.desafio['descricao'] ??
        widget.desafio['desc'] ??
        'Sem descrição.';
    final badge =
        widget.desafio['badgeExclusiva'] ??
        widget.desafio['reward'] ??
        '🏅 Insígnia';
    final xp = widget.desafio['recompensaXp']?.toString() ?? '0';

    final double progresso = _progressoReal;
    final double total = _totalReal;
    final double progressPercent = total > 0
        ? (progresso / total).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _concluido
                          ? Colors.green.withOpacity(0.1)
                          : const Color(0xFF06B6D4).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      color: _concluido
                          ? Colors.green
                          : const Color(0xFF06B6D4),
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "RECOMPENSA: $xp XP",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              "OBJETIVO DA MISSÃO",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              descricao,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            if (_aceito) ...[
              const SizedBox(height: 32),
              Text(
                _concluido ? "MISSÃO CONCLUÍDA!" : "SEU PROGRESSO",
                style: TextStyle(
                  color: _concluido ? Colors.green : const Color(0xFF06B6D4),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _concluido
                        ? Colors.green.withOpacity(0.3)
                        : Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 8,
                        backgroundColor: Colors.white10,
                        color: _concluido
                            ? Colors.green
                            : const Color(0xFF06B6D4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${(progressPercent * 100).toInt()}% Concluído",
                          style: TextStyle(
                            color: _concluido ? Colors.green : Colors.white54,
                            fontSize: 12,
                            fontWeight: _concluido
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        Text(
                          '${progresso.toStringAsFixed(1)} / ${total.toInt()} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            if (_concluido)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: const Center(
                  child: Text(
                    "🎉 PARABÉNS! VOCÊ VENCEU ESTE DESAFIO!",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 56,
                child: _isLoadingStatus
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF06B6D4),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _aceito || _isLoadingAction
                            ? null
                            : () => _aceitarDesafio(
                                context,
                                widget.desafio['id'],
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _aceito
                              ? Colors.amber.withOpacity(0.1)
                              : const Color(0xFF06B6D4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: _aceito
                                  ? Colors.amber
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: _isLoadingAction && !_aceito
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _aceito ? "EM ANDAMENTO" : "ACEITAR DESAFIO",
                                style: TextStyle(
                                  color: _aceito ? Colors.amber : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
              ),

            if (_aceito && !_concluido && !_isLoadingStatus) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isLoadingAction
                      ? null
                      : () => _cancelarDesafio(context, widget.desafio['id']),
                  child: _isLoadingAction && _aceito
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.redAccent,
                          ),
                        )
                      : const Text(
                          "ABANDONAR DESAFIO",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
