import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "SOBRE O PROJETO",
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Center(
              child: SizedBox(
                height: 100,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "FITLAB",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const Text(
              "Versão 1.0.0",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 40),

            // Card - Objetivo do App
            _buildAboutCard(
              title: "OBJETIVO",
              content:
                  "O FitLab é um aplicativo de acompanhamento dinâmico para praticantes de corrida e caminhada, integrando em um sistema unificado, as necessidades do atleta e as diretrizes do treinador, utilizando inteligência artificial para personalização dos treinos e mecânicas de gamificação com a finalidade de aumentar a retenção e motivação dos usuários",
            ),

            const SizedBox(height: 20),

            // Card de Equipe
            _buildAboutCard(
              title: "DESENVOLVIMENTO",
              content:
                  "Arthur Vital Fontana - 839832\nJoão Henrique Nazar Tavares - 839463\n\nInstituição: UNAERP\nDisciplina: Mobile II\nProfessor: Rodrigo de Oliveira Plotze\nTrabalho para composição da nota de avaliação parcial",
            ),

            const SizedBox(height: 40),
            const Divider(color: Colors.white10),
            const SizedBox(height: 20),
            const Text(
              "© 2026 TechIB. Todos os direitos reservados.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white10, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF06B6D4),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
