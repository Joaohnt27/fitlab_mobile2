class RadarAxis {
  final String label;
  final String icon;
  final String descricaoCientifica;

  RadarAxis({
    required this.label,
    required this.icon,
    required this.descricaoCientifica,
  });
}

final List<RadarAxis> eixosDoFitLab = [
  RadarAxis(
    label: 'VELOCIDADE',
    icon: '⚡',
    descricaoCientifica:
        'Métrica de Pace médio (tempo por km). Indica a capacidade explosiva e eficiência cardiovascular em ritmos altos.',
  ),
  RadarAxis(
    label: 'RESISTÊNCIA',
    icon: '🛡️',
    descricaoCientifica:
        'Capacidade de sustentar o esforço por longos períodos. Medida pela distância média e tempo contínuo de atividade.',
  ),
  RadarAxis(
    label: 'CONSISTÊNCIA',
    icon: '🔁',
    descricaoCientifica:
        'Índice de disciplina e adesão ao protocolo. Avalia a frequência semanal de treinos e o Streak (dias consecutivos).',
  ),
  RadarAxis(
    label: 'EXPLORAÇÃO',
    icon: '🌍',
    descricaoCientifica:
        'Diversidade de estímulos e adaptação. Mede a variedade de rotas e novos ambientes de treino registrados.',
  ),
];
