import 'package:flutter/material.dart';

import 'athlete_profile.dart';

class AppData {
  static ValueNotifier<Map<String, dynamic>?> experimentoAtivo = ValueNotifier(null);
  
  // Sistema de níveis
  static ValueNotifier<int> userXP = ValueNotifier(0);

  // Perfil do atleta
  static ValueNotifier<AthleteProfile> perfilAtleta = ValueNotifier(AthleteProfile());

  static void registrarCorrida({
    required double km,
    required double minutos,
    required bool novaRota,
  }) {
    var perfil = perfilAtleta.value;
    double pace = minutos / km;

    perfil.totalCorridas++;

    // Lógica de Atribuição de Pontos
    if (pace < 5.0) perfil.velocidade += 10; // pace rápido -> Velocidade
    if (km > 8.0) perfil.resistencia += 10;   // Distância longa -> Resistência
    if (novaRota) perfil.exploracao += 10;    // Rota nova -> Exploração
    perfil.consistencia += 5;                // Toda corrida gera consistência

    // Notifica os widgets da mudança
    perfilAtleta.notifyListeners();
    
    // Aproveita e ganha XP geral
    ganharXP(25);
  }

  // Função para ganhar XP
  static void ganharXP(int quantidade) {
    userXP.value += quantidade;
  }

  // Lógica de Tradução de XP para nome da patente
  static Map<String, dynamic> get nivelAtual {
    int xp = userXP.value;
    if (xp < 75) return {"lv": 1, "nome": "Recruta do laboratório", "icon": "🧪", "min": 0, "max": 75};
    if (xp < 115) return {"lv": 2, "nome": "Voluntário Ativo", "icon": "🧬", "min": 75, "max": 115};
    if (xp < 150) return {"lv": 3, "nome": "Testador de Performance", "icon": "📊", "min": 115, "max": 150};
    if (xp < 200) return {"lv": 4, "nome": "Atleta em análise", "icon": "🏃", "min": 150, "max": 200};
    if (xp < 260) return {"lv": 5, "nome": "Protótipo atlético", "icon": "🏋️", "min": 200, "max": 260};
    if (xp < 320) return {"lv": 6, "nome": "Modelo avançado", "icon": "💪", "min": 260, "max": 320};
    if (xp < 380) return {"lv": 7, "nome": "Unidade de Alta Performance", "icon": "⚡", "min": 320, "max": 380};
    return {"lv": 8, "nome": "Elite Experimental", "icon": "🎖️", "min": 380, "max": 1000};
  }

  static void salvarExperimento(String volume, String frequencia) {
    experimentoAtivo.value = {
      'volume': volume,
      'frequencia': frequencia,
      'progresso': 0.3,
      'diasRestantes': 7,
    };
    // Ganha 10 XP só por configurar um experimento
    ganharXP(10); 
  }
}