import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart'; // IMPORTANTE: Adicionei a importação do seu serviço

class UserProvider with ChangeNotifier {
  // Instância do serviço que se comunica com o Spring Boot
  final AuthService _authService = AuthService();

  // A lista _usuariosCadastrados foi removida, pois agora o banco de dados PostgreSQL é quem manda!

  Map<String, bool> _prefsNotificacoes = {
    'reminders': true,
    'achievements': true,
    'ranking': false,
    'marketing': false,
  };

  Map<String, bool> get prefsNotificacoes => _prefsNotificacoes;

  UserModel? _usuarioLogado;

  UserModel? get usuarioLogado => _usuarioLogado;
  String get nome => _usuarioLogado?.nome ?? "Usuário";

  // ==========================================
  // 1. NOVO LOGIN ASSÍNCRONO CONECTADO À API
  // ==========================================
  Future<bool> login(String email, String senha) async {
    try {
      // Chama a API Java
      UserModel? user = await _authService.fazerLogin(email, senha);

      if (user != null) {
        _usuarioLogado = user;

        // Mantive a sua lógica de gamificação para o usuário Elite!
        if (user.email == "fraga@email.com") {
          AppData.configurarPerfilElite();
          AppData.desbloquearConquistasDemo();
        } else {
          AppData.resetarPerfil();
        }

        notifyListeners();
        return true; // Login deu certo!
      }

      return false; // Retornou null (senha errada ou email não existe)
    } catch (e) {
      print("Erro no provedor durante o login: $e");
      return false;
    }
  }

  void logout() {
    _usuarioLogado = null;
    notifyListeners();
  }

  // ==========================================
  // 2. LÓGICAS DE PERFIL (Ajustadas para não depender da lista antiga)
  // ==========================================
  void atualizarPerfil({
    required String novoNome,
    String? novoAvatar,
    String? novaBio,
  }) {
    if (_usuarioLogado != null) {
      _usuarioLogado = _usuarioLogado!.copyWith(
        nome: novoNome,
        avatar: novoAvatar,
        bio: novaBio,
      );
      // TODO futuro: Enviar um HTTP PUT para o Java atualizar no banco de dados
      notifyListeners();
    }
  }

  void atualizarPerfilCompleto(UserModel usuarioAtualizado) {
    _usuarioLogado = usuarioAtualizado;
    notifyListeners();
  }

  // ==========================================
  // 3. GAMIFICAÇÃO, STREAKS E ALERTAS (Mantidos Intactos!)
  // ==========================================
  void mostrarAlertaBadge(BuildContext context, String nome, String icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF06B6D4)),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "NOVO BADGE DESBLOQUEADO!",
                      style: TextStyle(
                        color: Color(0xFF06B6D4),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      nome,
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
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void atualizarEstatisticas({
    int? novosTerritorios,
    int? novasConquistas,
    int? novoStreak,
    int? novoRanking,
  }) {
    if (_usuarioLogado != null) {
      _usuarioLogado = _usuarioLogado!.copyWith(
        territorios: novosTerritorios,
        conquistas: novasConquistas,
        streak: novoStreak,
        ranking: novoRanking,
      );
      notifyListeners();
    }
  }

  void salvarExperimentoUsuario(
    BuildContext context,
    String volume,
    String freq,
  ) {
    if (_usuarioLogado != null) {
      _usuarioLogado = _usuarioLogado!.copyWith(
        experimento: {
          'volume': volume,
          'frequencia': freq,
          'progresso': 0.0,
          'diasRestantes': 7,
        },
      );

      ganharXPeVerificarLevelUp(context, 10);

      int index = AppData.allBadges.indexWhere((b) => b.id == '1');
      if (index != -1 && !AppData.allBadges[index].isUnlocked) {
        AppData.allBadges[index] = AppData.allBadges[index].copyWith(
          isUnlocked: true,
        );

        _usuarioLogado = _usuarioLogado!.copyWith(
          conquistas: _usuarioLogado!.conquistas + 1,
        );

        mostrarAlertaBadge(
          context,
          AppData.allBadges[index].name,
          AppData.allBadges[index].icon,
        );
      }
      notifyListeners();
    }
  }

  void verificarEAtualizarStreak() {
    if (_usuarioLogado == null) return;

    final agora = DateTime.now();
    final ultimoLogin = _usuarioLogado!.ultimoLogin;

    if (ultimoLogin == null) {
      _usuarioLogado = _usuarioLogado!.copyWith(streak: 1, ultimoLogin: agora);
    } else {
      final diferenca = agora.difference(ultimoLogin).inHours;

      if (diferenca > 48) {
        _usuarioLogado = _usuarioLogado!.copyWith(
          streak: 0,
          ultimoLogin: agora,
        );
      } else if (diferenca >= 24) {
        _usuarioLogado = _usuarioLogado!.copyWith(
          streak: _usuarioLogado!.streak + 1,
          ultimoLogin: agora,
        );
      }
    }
    notifyListeners();
  }

  void ganharXPeVerificarLevelUp(BuildContext context, int quantidade) {
    if (_usuarioLogado == null) return;

    final nivelAntes = AppData.getNivelByXP(_usuarioLogado!.xp);
    _usuarioLogado = _usuarioLogado!.copyWith(
      xp: _usuarioLogado!.xp + quantidade,
    );
    final nivelDepois = AppData.getNivelByXP(_usuarioLogado!.xp);

    if (nivelDepois['lv'] > nivelAntes['lv']) {
      _mostrarDialogoLevelUp(context, nivelDepois);
    }
    notifyListeners();
  }

  void _mostrarDialogoLevelUp(
    BuildContext context,
    Map<String, dynamic> novoNivel,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "🚀 NOVO NÍVEL ALCANÇADO!",
                style: TextStyle(
                  color: Color(0xFF06B6D4),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Text(novoNivel['icon'], style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 10),
              Text(
                "PATENTE: ${novoNivel['nome']}".toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Sua biometria evoluiu. Você desbloqueou novas capacidades no laboratório.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                  ),
                  child: const Text(
                    "CONTINUAR EVOLUÇÃO",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void alternarNotificacao(String chave, bool valor) {
    _prefsNotificacoes[chave] = valor;
    notifyListeners();
  }
}
