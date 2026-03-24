class UserModel {
  final String nome;
  final String email;
  final String senha;
  final int nivel;
  final int xp;
  final String classe;
  final String avatar;
  final String bio;

  UserModel({
    required this.nome,
    required this.email,
    required this.senha,
    this.nivel = 1, // Padrão: nível 1
    this.xp = 0, // Padrão: 0 XP
    this.classe = "Recruta", // Padrão: Recruta
    this.avatar = "🧪", // Avatar padrão
    this.bio = "Olá! Sou um entusiasta do FitLab e estou aqui para experimentar novas rotinas de treino. Vamos juntos nessa jornada de evolução física!",
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
    );
  }
}
