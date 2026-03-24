import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _currentAvatar; // Guarda o avatar selecionado localmente

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(
      context,
      listen: false,
    ).usuarioLogado;
    _nameController = TextEditingController(text: user?.nome);
    _bioController = TextEditingController(text: user?.bio);
    _currentAvatar = user?.avatar ?? "🧪"; // Inicializa com o avatar atual
  }

  // Painel de seleção de avatar estilo Duolingo/CyberLab
  void _showAvatarSelector() {
    final List<String> availableAvatars = [
      "🧪",
      "🧬",
      "🏃‍♂️",
      "⚡",
      "🦇",
      "🕸️",
      "🏎️",
      "🏆",
      "🌳",
      "🎯",
      "🦾",
      "🔥",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "SELECIONE SEU AVATAR DE PROTOCOLO",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: availableAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = availableAvatars[index];
                  final isSelected = avatar == _currentAvatar;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentAvatar = avatar);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF06B6D4).withOpacity(0.1)
                            : Colors.black26,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF06B6D4)
                              : Colors.white10,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(avatar, style: const TextStyle(fontSize: 30)),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() {
    final provider = Provider.of<UserProvider>(context, listen: false);

    // Agora enviamos o nome e o avatar selecionado
    provider.atualizarPerfil(
      novoNome: _nameController.text,
      novoAvatar: _currentAvatar,
      novaBio: _bioController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Protocolo de perfil atualizado!"),
        backgroundColor: Color(0xFF06B6D4),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text(
          "EDITAR PERFIL",
          style: TextStyle(letterSpacing: 2, fontSize: 14),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar Interativo
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF1A1A1A),
                    child: Text(
                      _currentAvatar ?? "🧪",
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF06B6D4),
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.black,
                      ),
                      onPressed: _showAvatarSelector, // Abre o seletor
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            _buildEditField("NOME DO ATLETA", _nameController),
            const SizedBox(height: 20),
            _buildEditField("BIO / OBJETIVO", _bioController, maxLines: 3),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "SALVAR ALTERAÇÕES",
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
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF06B6D4)),
            ),
          ),
        ),
      ],
    );
  }
}
