import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';

class RegisterStaffScreen extends StatefulWidget {
  const RegisterStaffScreen({super.key});

  @override
  State<RegisterStaffScreen> createState() => _RegisterStaffScreenState();
}

class _RegisterStaffScreenState extends State<RegisterStaffScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isLoading = false;
  bool _isObscurePass = true;

  Future<void> _registerStaff() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _codeController.text.isEmpty) {
      _showSnackBar('Preencha todos os campos obrigatórios!', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    final payload = {
      "nome": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "senha": _passwordController.text,
      "codigoEquipe": _codeController.text.trim().toUpperCase(),
    };

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/equipes/cadastrar-staff'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(payload),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(
          'Credencial Staff criada com sucesso! Faça login.',
          Colors.green,
        );
        Navigator.pop(context); // Volta para a tela de login/cadastro
      } else {
        _showSnackBar(response.body, Colors.redAccent);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Erro de conexão com o servidor.', Colors.redAccent);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.shield_rounded,
              color: Color(0xFF06B6D4),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "ENTRAR EM UMA EQUIPE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Insira o código de convite da assessoria ELITE para ingressar como Treinador Staff.",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            _buildField(
              controller: _nameController,
              label: 'NOME COMPLETO',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _emailController,
              label: 'E-MAIL PROFISSIONAL',
              icon: Icons.alternate_email,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _passwordController,
              label: 'SENHA DE ACESSO',
              icon: Icons.lock_outline,
              isPass: _isObscurePass,
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscurePass ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white38,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _isObscurePass = !_isObscurePass),
              ),
            ),
            const SizedBox(height: 32),

            // CAMPO DE CÓDIGO DESTACADO
            TextField(
              controller: _codeController,
              style: const TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: "CÓDIGO DE CONVITE",
                labelStyle: const TextStyle(
                  color: Color(0xFF06B6D4),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                filled: true,
                fillColor: const Color(0xFF06B6D4).withOpacity(0.1),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: const Color(0xFF06B6D4).withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF06B6D4),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerStaff,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "VALIDAR CONVITE",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPass = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF06B6D4),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.black,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF06B6D4)),
        ),
      ),
    );
  }
}
