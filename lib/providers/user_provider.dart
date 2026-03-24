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
    ),
    UserModel(
      nome: "Usuário Teste - UA",
      email: "teste@teste.com",
      senha: "123",
      avatar: "🧪",
    ),
  ];

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

      // Lógica de Mock
      if (user.email == "fraga@email.com") {
        AppData.userXP.value = user.xp;
        AppData.configurarPerfilElite();
        AppData.desbloquearConquistasDemo();
      } else {
        AppData.userXP.value = 0;
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

        // Atualiza a referência na lista global de usuários
        int index = _usuariosCadastrados.indexWhere(
          (u) => u.email == _usuarioLogado!.email,
        );
        if (index != -1) _usuariosCadastrados[index] = _usuarioLogado!;

        notifyListeners(); // Faz o Grid de Stats da ProfileScreen atualizar na hora!
      }
    }
  }
}
