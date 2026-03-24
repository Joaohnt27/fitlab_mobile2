class UserModel {
  final String nome;
  final String email;
  final String senha;
  final int nivel;
  final int xp;
  final String classe;
  final String avatar;
  final String bio;
  final int territorios;
  final int conquistas;
  final int streak;
  final int ranking;
  final DateTime? ultimoLogin;
  final Map<String, dynamic>? experimento;

  UserModel({
    required this.nome,
    required this.email,
    required this.senha,
    this.nivel = 1, // Padrão: nível 1
    this.xp = 0, // Padrão: 0 XP
    this.classe = "Recruta", // Padrão: Recruta
    this.avatar = "🧪", // Avatar padrão
    this.bio =
        "Olá! Sou um entusiasta do FitLab e estou aqui para experimentar novas rotinas de treino. Vamos juntos nessa jornada de evolução física!",
    this.territorios = 0,
    this.conquistas = 0,
    this.streak = 0,
    this.ranking = 0,
    this.experimento,
    this.ultimoLogin,
  });

  UserModel copyWith({
    String? nome,
    String? email,
    String? senha,
    int? nivel,
    int? xp,
    String? classe,
    String? avatar,
    String? bio,
    int? territorios,
    int? conquistas,
    int? streak,
    int? ranking,
    Map<String, dynamic>? experimento,
    DateTime? ultimoLogin,
  }) {
    return UserModel(
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      nivel: nivel ?? this.nivel,
      xp: xp ?? this.xp,
      classe: classe ?? this.classe,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      territorios: territorios ?? this.territorios,
      conquistas: conquistas ?? this.conquistas,
      streak: streak ?? this.streak,
      ranking: ranking ?? this.ranking,
      experimento: experimento ?? this.experimento,
      ultimoLogin: ultimoLogin ?? this.ultimoLogin,
    );
  }
}
