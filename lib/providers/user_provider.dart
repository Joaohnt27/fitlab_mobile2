import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  // Lista em memória
  final List<UserModel> _usuariosCadastrados = [
    UserModel(
      nome: "João Frag",
      email: "fraga@email.com",
      senha: "fraga",
      nivel: 42,
      xp: 400,
      classe: "Elite Experimental",
      avatar: "🧬",
      territorios: 6,
      conquistas: 7,
      streak: 15,
      ranking: 1,
      ultimoLogin: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    UserModel(
      nome: "Usuário Teste - UA",
      email: "teste@teste.com",
      senha: "123",
      avatar: "🧪",
    ),
  ];

  Map<String, bool> _prefsNotificacoes = {
    'reminders': true,
    'achievements': true,
    'ranking': false,
    'marketing': false,
  };

  // 2. Crie um Getter para a UI ler os valores
  Map<String, bool> get prefsNotificacoes => _prefsNotificacoes;

  UserModel? _usuarioLogado;

  UserModel? get usuarioLogado => _usuarioLogado;
  String get nome => _usuarioLogado?.nome ?? "Usuário";

  // Método para Criar Conta
  bool registrar(String nome, String email, String senha) {
    // Verifica se o e-mail já existe
    if (_usuariosCadastrados.any((u) => u.email == email)) return false;

    _usuariosCadastrados.add(UserModel(nome: nome, email: email, senha: senha));
    notifyListeners();
    return true;
  }

  // Método para Logar
  bool login(String email, String senha) {
    try {
      final user = _usuariosCadastrados.firstWhere(
        (u) => u.email == email && u.senha == senha,
      );
      _usuarioLogado = user;

      if (user.email == "fraga@email.com") {
        AppData.configurarPerfilElite();
        AppData.desbloquearConquistasDemo();
      } else {
        AppData.resetarPerfil();
      }

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _usuarioLogado = null;
    notifyListeners();
  }

  void atualizarPerfil({
    required String novoNome,
    String? novoAvatar,
    String? novaBio,
  }) {
    if (_usuarioLogado != null) {
      // Usa copyWith para criar o novo estado do usuário
      _usuarioLogado = _usuarioLogado!.copyWith(
        nome: novoNome,
        avatar: novoAvatar,
        bio: novaBio,
      );

      // Atualiza também na lista de cadastrados (persistência em memória)
      int index = _usuariosCadastrados.indexWhere(
        (u) => u.email == _usuarioLogado!.email,
      );
      if (index != -1) _usuariosCadastrados[index] = _usuarioLogado!;

      notifyListeners(); // ISSO FAZ O PERFIL E A TELA DE EDIÇÃO ATUALIZAREM!!!!!
    }
  }

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

      ganharXPeVerificarLevelUp(
        context,
        10,
      ); // Quanto que ganha de xp a cada experimento criado

      //Lógica de Desbloqueio do Badge
      int index = AppData.allBadges.indexWhere((b) => b.id == '1');
      if (index != -1 && !AppData.allBadges[index].isUnlocked) {
        AppData.allBadges[index] = AppData.allBadges[index].copyWith(
          isUnlocked: true,
        );

        // Incrementa o contador de conquistas no perfil do usuário
        _usuarioLogado = _usuarioLogado!.copyWith(
          conquistas: _usuarioLogado!.conquistas + 1,
        );

        // Dispara o Alerta de Badge
        mostrarAlertaBadge(
          context,
          AppData.allBadges[index].name,
          AppData.allBadges[index].icon,
        );
      }

      // Sincroniza na lista de memória
      int userIndex = _usuariosCadastrados.indexWhere(
        (u) => u.email == _usuarioLogado!.email,
      );
      if (userIndex != -1) _usuariosCadastrados[userIndex] = _usuarioLogado!;

      notifyListeners();
    }
  }

  void atualizarStreak(UserModel user) {
    if (user.ultimoLogin == null) return;

    final agora = DateTime.now();
    final diferenca = agora.difference(user.ultimoLogin!);

    if (diferenca.inHours > 48) {
      // Perdeu o fogo! Passou de 2 dias sem logar
      atualizarEstatisticas(novoStreak: 0);
    } else if (diferenca.inHours > 24) {
      // Logou no dia seguinte, sobe a sequência
      atualizarEstatisticas(novoStreak: user.streak + 1);
    }
    // Atualiza a data de acesso para a próxima verificação
    _usuarioLogado = _usuarioLogado!.copyWith(ultimoLogin: agora);
  }

  void verificarEAtualizarStreak() {
    if (_usuarioLogado == null) return;

    final agora = DateTime.now();
    final ultimoLogin = _usuarioLogado!.ultimoLogin;

    if (ultimoLogin == null) {
      // USUÁRIO NOVO: Primeiro login da vida dele
      _usuarioLogado = _usuarioLogado!.copyWith(
        streak: 1, // Começa com 1 porque ele está logado agora
        ultimoLogin: agora,
      );
    } else {
      final diferenca = agora.difference(ultimoLogin).inHours;

      if (diferenca > 48) {
        // PERDEU A SEQUÊNCIA: Passou mais de um dia sem logar (tolerância de 48h)
        _usuarioLogado = _usuarioLogado!.copyWith(
          streak: 0,
          ultimoLogin: agora,
        );
      } else if (diferenca >= 24) {
        // SUBIU A SEQUÊNCIA: Logou no dia seguinte
        _usuarioLogado = _usuarioLogado!.copyWith(
          streak: _usuarioLogado!.streak + 1,
          ultimoLogin: agora,
        );
      }
      // Se a diferença for < 24h, ele apenas logou no mesmo dia, então mantém o streak
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

  // Widget de Level Up
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
    notifyListeners(); // Isso faz os switches da tela mudarem de posição!
  }
}
