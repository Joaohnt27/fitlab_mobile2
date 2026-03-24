import 'package:flutter/material.dart';

import 'athlete_profile.dart';
import 'badge_model.dart';

class AppData {
  static ValueNotifier<Map<String, dynamic>?> experimentoAtivo = ValueNotifier(
    null,
  );

  // Perfil do atleta
  static ValueNotifier<AthleteProfile> perfilAtleta = ValueNotifier(
    AthleteProfile(),
  );

  // Método para configurar o perfil de um usuário "Elite" (mock)
  static void configurarPerfilElite() {
    perfilAtleta.value = AthleteProfile(
      totalCorridas: 154,
      velocidade: 95,
      resistencia: 90,
      exploracao: 85,
      consistencia: 100,
    );
    perfilAtleta.notifyListeners();
  }

  static void resetarPerfil() {
    perfilAtleta.value = AthleteProfile();

    allBadges = allBadges.map((b) => b.copyWith(isUnlocked: false)).toList();

    perfilAtleta.notifyListeners();
  }

  static void desbloquearConquistasDemo() {
    List<BadgeModel> novaLista = [];

    for (int i = 0; i < allBadges.length; i++) {
      if (i < allBadges.length - 2) {
        novaLista.add(allBadges[i].copyWith(isUnlocked: true));
      } else {
        novaLista.add(allBadges[i]); // Mantém bloqueado
      }
    }

    allBadges = novaLista;
    perfilAtleta.notifyListeners(); // Notifica a UI para colorir os ícones
  }

  // Lógica de Tradução de XP para nome da patente
  static final List<Map<String, dynamic>> levels = [
    {
      "lv": 1,
      "nome": "Recruta do laboratório",
      "icon": "🧪",
      "min": 0,
      "max": 75,
    },
    {"lv": 2, "nome": "Voluntário Ativo", "icon": "🧬", "min": 76, "max": 115},
    {
      "lv": 3,
      "nome": "Testador de Performance",
      "icon": "📊",
      "min": 116,
      "max": 150,
    },
    {
      "lv": 4,
      "nome": "Atleta em análise",
      "icon": "🏃",
      "min": 151,
      "max": 200,
    },
    {
      "lv": 5,
      "nome": "Protótipo atlético",
      "icon": "🏋️",
      "min": 201,
      "max": 260,
    },
    {"lv": 6, "nome": "Modelo avançado", "icon": "💪", "min": 261, "max": 320},
    {
      "lv": 7,
      "nome": "Unidade de Alta Performance",
      "icon": "⚡",
      "min": 321,
      "max": 380,
    },
    {
      "lv": 8,
      "nome": "Elite Experimental",
      "icon": "🎖️",
      "min": 381,
      "max": 10000,
    },
  ];

  static Map<String, dynamic> getNivelAtual(int xp) {
    return levels.firstWhere(
      (lvl) => xp >= lvl['min'] && xp <= lvl['max'],
      orElse: () => levels.last,
    );
  }

  static void desbloquearPrimeiroBadge() {
    int index = allBadges.indexWhere((b) => b.id == '1');
    if (index != -1) {
      allBadges[index] = allBadges[index].copyWith(isUnlocked: true);
      perfilAtleta.notifyListeners();
    }
  }

  static Map<String, dynamic> getNivelByXP(int xp) {
    return levels.firstWhere(
      (lvl) => xp >= lvl['min'] && xp <= lvl['max'],
      orElse: () => levels.last,
    );
  }

  static List<BadgeModel> allBadges = [
    BadgeModel(
      id: '1',
      name: 'Primeiro Experimento',
      icon: '🧪',
      rarity: BadgeRarity.common,
      isUnlocked: false,
      theme: 'O laboratório',
      requisito:
          'Complete seu primeiro experimento configurando um volume e frequência de treino.',
    ),
    BadgeModel(
      id: '2',
      name: 'Teste de Campo',
      icon: '🔬',
      rarity: BadgeRarity.common,
      isUnlocked: false,
      theme: 'O laboratório',
      requisito: 'Corra 3 dias na semana.',
    ),
    BadgeModel(
      id: '3',
      name: 'Experimento Estável',
      icon: '⚗️',
      rarity: BadgeRarity.rare,
      isUnlocked: false,
      theme: 'O laboratório',
      requisito: 'Corra por duas semanas seguidas.',
    ),
    BadgeModel(
      id: '4',
      name: 'Experimento Promissor',
      icon: '📈',
      rarity: BadgeRarity.rare,
      isUnlocked: false,
      theme: 'O laboratório',
      requisito: 'Complete sua meta definida no experimento.',
    ),
    BadgeModel(
      id: '5',
      name: 'Protótipo Atlético',
      icon: '🧬',
      rarity: BadgeRarity.epic,
      isUnlocked: false,
      theme: 'O laboratório',
      requisito: 'Corra um total de 50 km.',
    ),
    BadgeModel(
      id: '6',
      name: 'Experimento de Elite',
      icon: '💎',
      rarity: BadgeRarity.legendary,
      isUnlocked: false,
      theme: 'O laboratório',
      requisito: 'Corra um total de 200 km.',
    ),
    BadgeModel(
      id: '7',
      name: 'Velocidade de Ignição',
      icon: '⚡',
      rarity: BadgeRarity.rare,
      isUnlocked: false,
      theme: 'DC Comics',
      requisito: 'Corra 100m em 20 segundos.',
    ),
    BadgeModel(
      id: '8',
      name: 'Treino do Cavaleiro das Trevas',
      icon: '🦇',
      rarity: BadgeRarity.epic,
      isUnlocked: false,
      theme: 'DC Comics',
      requisito: 'Corra por 7 dias seguidos.',
    ),
    BadgeModel(
      id: '9',
      name: 'Sentido Aranha',
      icon: '🕸️',
      rarity: BadgeRarity.epic,
      isUnlocked: false,
      theme: 'Marvel',
      requisito: 'Melhore seu tempo 3 vezes.',
    ),
    BadgeModel(
      id: '10',
      name: 'Vigilante Noturno',
      icon: '🌃',
      rarity: BadgeRarity.common,
      isUnlocked: false,
      theme: 'DC Comics',
      requisito: 'Corra à noite.',
    ),
    BadgeModel(
      id: '11',
      name: 'Salvador do Multiverso',
      icon: '🦾',
      rarity: BadgeRarity.legendary,
      isUnlocked: false,
      theme: 'Marvel',
      requisito: 'Corra 5 km em menos de 30 minutos.',
    ),
    BadgeModel(
      id: '12',
      name: 'Largada Perfeita',
      icon: '🏁',
      rarity: BadgeRarity.common,
      isUnlocked: false,
      theme: 'Fórmula 1',
      requisito: 'Inicie sua primeira corrida.',
    ),
    BadgeModel(
      id: '13',
      name: 'Volta rápida',
      icon: '🏎️',
      rarity: BadgeRarity.rare,
      isUnlocked: false,
      theme: 'Fórmula 1',
      requisito: 'Bata seu tempo recorde.',
    ),
    BadgeModel(
      id: '14',
      name: 'Pole Position',
      icon: '🏆',
      rarity: BadgeRarity.legendary,
      isUnlocked: false,
      theme: 'Fórmula 1',
      requisito: 'Alcance o primeiro lugar no ranking.',
    ),
  ];
}
