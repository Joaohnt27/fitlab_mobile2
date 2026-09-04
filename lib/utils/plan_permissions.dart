class PlanPermissions {
  final String plano;

  PlanPermissions(this.plano);

  String get _normalized => plano.toUpperCase();

  bool get isStart => _normalized.contains('START');
  bool get isPro => _normalized.contains('PRO');
  bool get isElite => _normalized.contains('ELITE');
  bool get isStaff => _normalized.contains('STAFF');

  bool get canUseAI => isPro || isElite || isStaff;

  bool get canUseLibrary => isPro || isElite;

  bool get canManageTeam => isElite;

  bool get canCreateChallenge => isPro || isElite;

  bool get canCreatePublicChallenges => isElite;

  // Retorna a string visual do limite
  String get limitStudents {
    if (isStart) return "20";
    if (isPro) return "60";
    if (isElite) return "500";
    if (isStaff) return "Equipe";
    return "20";
  }
}
