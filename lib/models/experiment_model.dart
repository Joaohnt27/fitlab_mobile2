class Experiment {
  final String volumeMeta;
  final String frequenciaMeta;
  final double progressoAtual;
  bool ativo;

  Experiment({
    required this.volumeMeta,
    required this.frequenciaMeta,
    this.progressoAtual = 0.0,
    this.ativo = false,
  });
}
