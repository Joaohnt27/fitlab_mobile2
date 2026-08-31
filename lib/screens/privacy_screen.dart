import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  void _mostrarMensagem(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Colors.redAccent : const Color(0xFF06B6D4),
      ),
    );
  }

  void _showEditEmailDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "ALTERAR E-MAIL",
          style: TextStyle(
            color: Color(0xFF06B6D4),
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        content: TextField(
          controller: emailController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Digite o novo e-mail",
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF06B6D4)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCELAR",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.isEmpty) return;

              final provider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              final erro = await provider.atualizarEmail(emailController.text);

              if (!mounted) return;
              Navigator.pop(context); 

              if (erro == null) {
                _mostrarMensagem("E-mail atualizado com sucesso!");
              } else {
                _mostrarMensagem(erro, erro: true);
              }
            },
            child: const Text(
              "SALVAR",
              style: TextStyle(color: Color(0xFF06B6D4)),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPasswordDialog(BuildContext context) {
    final senhaAtualController = TextEditingController();
    final novaSenhaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "ALTERAR SENHA",
          style: TextStyle(
            color: Color(0xFF06B6D4),
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: senhaAtualController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Senha atual",
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: novaSenhaController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Nova senha",
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCELAR",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (senhaAtualController.text.isEmpty ||
                  novaSenhaController.text.isEmpty)
                return;

              final provider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              final erro = await provider.atualizarSenha(
                senhaAtualController.text,
                novaSenhaController.text,
              );

              if (!mounted) return;
              Navigator.pop(context);

              if (erro == null) {
                _mostrarMensagem("Senha atualizada com sucesso!");
              } else {
                _mostrarMensagem(erro, erro: true);
              }
            },
            child: const Text(
              "SALVAR",
              style: TextStyle(color: Color(0xFF06B6D4)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Excluir Conta?",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Você tem certeza? Todo o seu XP, conquistas e histórico de corridas serão perdidos permanentemente.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCELAR",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              final provider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              final sucesso = await provider.excluirConta();

              if (!mounted) return;

              if (sucesso) {
                // Tira a pessoa do aplicativo e joga pro login
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              } else {
                Navigator.pop(context); // Fecha o dialog
                _mostrarMensagem(
                  "Erro ao excluir conta. Verifique dependências.",
                  erro: true,
                );
              }
            },
            child: const Text(
              "EXCLUIR",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).usuarioLogado;
    final userEmail = user?.email ?? "Carregando e-mail...";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "PRIVACIDADE E CONTA",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "DADOS DE ACESSO",
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              icon: Icons.email_outlined,
              title: "E-mail cadastrado",
              subtitle: userEmail,
              onTap: () => _showEditEmailDialog(context),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              icon: Icons.lock_outline,
              title: "Alterar Senha",
              subtitle: "Atualize sua segurança",
              onTap: () => _showEditPasswordDialog(context),
            ),
            const SizedBox(height: 40),
            const Text(
              "ZONA DE PERIGO",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.delete_forever,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  "Excluir Minha Conta",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "Esta ação é irreversível e apaga todos os treinos.",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                onTap: () => _showDeleteConfirmation(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      tileColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(icon, color: const Color(0xFF06B6D4)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
    );
  }
}
