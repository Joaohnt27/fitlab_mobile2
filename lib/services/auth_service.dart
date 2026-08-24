import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart'; 

class AuthService {
  static const String baseUrl = 'http://localhost:8080/api/atletas';

  // Cadastra um novo atleta no back-end
  Future<UserModel?> cadastrarAtleta(UserModel usuario) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cadastro'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(usuario.toJson()), 
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> dadosRetornados = jsonDecode(response.body);
        return UserModel.fromJson(dadosRetornados); 
      } else {
        print('Erro no back-end: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (erro) {
      print('Erro de conexão com a API: $erro');
      return null;
    }
  }

  // Faz o login de um usuário no back-end
  Future<UserModel?> fazerLogin(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        return null; 
      }
    } catch (e) {
      print('Erro de conexão no login: $e');
      return null;
    }
  }
}