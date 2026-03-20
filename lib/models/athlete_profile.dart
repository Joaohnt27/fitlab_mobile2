class AthleteProfile {
  int velocidade;
  int resistencia;
  int consistencia;
  int exploracao;
  int totalCorridas;

  AthleteProfile({
    this.velocidade = 0,
    this.resistencia = 0,
    this.consistencia = 0,
    this.exploracao = 0,
    this.totalCorridas = 0,
  });

  // cálculo da classe em tempo real
  String get classeIdentificada {
    if (totalCorridas < 3) return "Analisando DNA...";

    Map<String, int> scores = {
      '⚡ Velocista': velocidade,
      '🛡️ Resistente': resistencia,
      '🔁 Consistente': consistencia,
      '🌍 Explorador': exploracao,
    };

    // Verifica se é Híbrido (se a diferença entre o maior e o menor for pequena)
    var valores = scores.values.toList()..sort();
    if (valores.last - valores.first < 5 && totalCorridas > 5) {
      return "🧬 Híbrido";
    }

    // Retorna a chave com o maior valor
    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
