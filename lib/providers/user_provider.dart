import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _nome = "Usuário";
  String _email = "";
  String _telefone = "";

  // Getters para acessar os dados nas telas (Perfil, Home, etc)
  String get nome => _nome;
  String get email => _email;
  String get telefone => _telefone;

  // Método que a SignupScreen chama para salvar os dados
  void realizarCadastro(
    String novoNome,
    String novoEmail,
    String novoTelefone,
  ) {
    _nome = novoNome;
    _email = novoEmail;
    _telefone = novoTelefone;

    notifyListeners();
  }

  void realizarLogin(String emailInformado) {
    _email = emailInformado;
    notifyListeners();
  }
}
