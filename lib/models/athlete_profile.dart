class AthleteProfile {
  int velocidade;
  int resistencia;
  int consistencia;
  int exploracao;
  int totalCorridas;

  static const int maxPontosPorAtributo = 100;

  AthleteProfile({
    this.velocidade = 0,
    this.resistencia = 0,
    this.consistencia = 0,
    this.exploracao = 0,
    this.totalCorridas = 0,
  });

  String get classeIdentificada {
    if (totalCorridas < 3) return "Analisando DNA esportivo..."; // Período de calibração

    Map<String, int> scores = {
      '⚡ Velocista': velocidade,
      '🛡️ Resistente': resistencia,
      '🔁 Consistente': consistencia,
      '🌍 Explorador': exploracao,
    };

    // Verifica se é Híbrido (se a diferença entre o maior e o menor for pequena)
    var valores = scores.values.toList()..sort();
    if (valores.last - valores.first < 20 && totalCorridas > 5) {
      return "🧬 Híbrido";
    }

    // Retorna a chave com o maior valor
    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // NOVA FUNÇÃO: Retorna os dados normalizados para o gráfico
  Map<String, double> get normalizedData {
    return {
      '⚡ VELOCIDADE': (velocidade / maxPontosPorAtributo).clamp(0.0, 1.0),
      '🛡️ RESISTÊNCIA': (resistencia / maxPontosPorAtributo).clamp(0.0, 1.0),
      '🔁 CONSISTÊNCIA': (consistencia / maxPontosPorAtributo).clamp(0.0, 1.0),
      '🌍 EXPLORAÇÃO': (exploracao / maxPontosPorAtributo).clamp(0.0, 1.0),
    };
  }
}
