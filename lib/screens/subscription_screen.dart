import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../widgets/plan_card.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final usuario = userProvider.usuarioLogado;
    final bool isTreinador = usuario?.role == 'Treinador';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "CENTRAL DE ASSINATURAS",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentPlanHeader(usuario),
            const SizedBox(height: 40),
            Text(
              isTreinador ? "PLANOS PARA CIENTISTAS" : "UPGRADES BIOMÉTRICOS",
              style: const TextStyle(
                color: Color(0xFF06B6D4),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Escolha sua próxima evolução",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Sincronização automática baseada no Role
            if (isTreinador)
              ..._buildCoachPlans(context, usuario)
            else
              ..._buildAthletePlans(context, usuario),

            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Cobrança processada via FitLab Pay",
                style: TextStyle(color: Colors.white24, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanHeader(UserModel? usuario) {
    final String nomePlanoAtual = usuario?.plano?['nome'] ?? "FREE";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user, color: Color(0xFF06B6D4), size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "NÍVEL ATUAL",
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
              Text(
                nomePlanoAtual.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCoachPlans(BuildContext context, UserModel? usuario) {
    final String nomePlanoAtual = usuario?.plano?['nome'] ?? "Free";

    return [
      PlanCard(
        title: "Coach Start",
        price: "R\$ 49,90",
        accentColor: Colors.white70,
        isCurrentPlan: nomePlanoAtual == "Coach Start",
        features: ["Até 20 alunos", "Criar treinos", "Ranking interno"],
        onTap: () => _handlePlanAction(context, nomePlanoAtual, "Coach Start"),
      ),
      PlanCard(
        title: "Coach Pro",
        price: "R\$ 99,90",
        accentColor: const Color(0xFF06B6D4),
        isRecommended: true,
        isCurrentPlan: nomePlanoAtual == "Coach Pro",
        features: [
          "Até 60 alunos",
          "Estatísticas avançadas",
          "IA para treinos",
        ],
        onTap: () => _handlePlanAction(context, nomePlanoAtual, "Coach Pro"),
      ),
      PlanCard(
        title: "Coach Elite",
        price: "R\$ 179,90",
        accentColor: const Color(0xFF1D4ED8),
        isCurrentPlan: nomePlanoAtual == "Coach Elite",
        features: ["Alunos ilimitados", "Gestão de equipe", "Automação total"],
        onTap: () => _handlePlanAction(context, nomePlanoAtual, "Coach Elite"),
      ),
    ];
  }

  List<Widget> _buildAthletePlans(BuildContext context, UserModel? usuario) {
    final String nomePlanoAtual = usuario?.plano?['nome'] ?? "Free";

    return [
      PlanCard(
        title: "Atleta Pro",
        price: "R\$ 29,90",
        accentColor: const Color(0xFF06B6D4),
        isRecommended: true,
        isCurrentPlan: nomePlanoAtual == "Atleta Pro",
        features: [
          "Treinos IA ilimitados",
          "Análise biomecânica",
          "Sem anúncios",
        ],
        onTap: () => _handlePlanAction(context, nomePlanoAtual, "Atleta Pro"),
      ),
      PlanCard(
        title: "Atleta Elite",
        price: "R\$ 49,90",
        accentColor: const Color(0xFF1D4ED8),
        isCurrentPlan: nomePlanoAtual == "Atleta Elite",
        features: [
          "Acesso a Coaches",
          "Consultoria personalizada",
          "Ranking global",
        ],
        onTap: () => _handlePlanAction(context, nomePlanoAtual, "Atleta Elite"),
      ),
    ];
  }

  // Gerencia se deve abrir compra ou cancelamento
  void _handlePlanAction(
    BuildContext context,
    String planoAtual,
    String planoAlvo,
  ) {
    if (planoAtual == planoAlvo) {
      _confirmarCancelamento(context);
    } else {
      _simularCompra(context, planoAlvo);
    }
  }

  void _confirmarCancelamento(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "CANCELAR SÍNTESE?",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: const Text(
          "Você perderá acesso aos recursos premium do seu nível atual ao final do ciclo de cobrança.",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "MANTER PLANO",
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _processarUpgradeOuCancelamento(context, "Free");
            },
            child: const Text(
              "CONFIRMAR",
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

  void _simularCompra(BuildContext context, String novoPlano) {
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
              const CircularProgressIndicator(color: Color(0xFF06B6D4)),
              const SizedBox(height: 24),
              const Text(
                "SINTETIZANDO ACESSO...",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Configurando nível $novoPlano",
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); 
      _processarUpgradeOuCancelamento(context, novoPlano);
    });
  }

  void _processarUpgradeOuCancelamento(BuildContext context, String planoNome) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    if (provider.usuarioLogado != null) {
      provider.atualizarPerfilCompleto(
        provider.usuarioLogado!.copyWith(plano: {"nome": planoNome}),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Plano atualizado para: $planoNome"),
          backgroundColor: const Color(0xFF06B6D4),
        ),
      );
    }
  }
}
