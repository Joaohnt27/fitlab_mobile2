import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart'; 

class AuthService {
  static const String baseUrl = 'http://localhost:8080/api/atletas';

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
}