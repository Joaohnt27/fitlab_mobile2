class UserModel {
  final String nome;
  final String email;
  final String senha;
  final double? peso;
  final double? altura;
  final int nivel;
  final int xp;
  final String classe;
  final String avatar;
  final String bio;
  final int territorios;
  final int conquistas;
  final int streak;
  final int ranking;
  final String role;
  final String plano;
  final DateTime? ultimoLogin;
  final Map<String, dynamic>? experimento;

  UserModel({
    required this.nome,
    required this.email,
    required this.senha,
    this.peso,
    this.altura,
    this.nivel = 1,
    this.xp = 0,
    this.classe = "Recruta",
    this.avatar = "🧪",
    this.bio =
        "Olá! Sou um entusiasta do FitLab e estou aqui para experimentar novas rotinas de treino.",
    this.territorios = 0,
    this.conquistas = 0,
    this.streak = 0,
    this.ranking = 0,
    this.role = "Atleta",
    this.plano = "Free",
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
    String? role,
    String? plano,
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
      role: role ?? this.role,
      plano: plano ?? this.plano,
      experimento: experimento ?? this.experimento,
      ultimoLogin: ultimoLogin ?? this.ultimoLogin,
    );
  }

  // Converte o objeto Dart para um mapa JSON (vai ser enviado para a API)
  Map<String, dynamic> toJson() {
    return {
      "nome": nome,
      "email": email,
      "senha": senha,
      "peso": peso,
      "altura": altura,
    };
  }

  // Cria um objeto Dart a partir de um JSON (Quando a API devolver os dados)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      senha:
          json['senha'] ??
          '', 
      xp:
          json['xpAcumulado'] ??
          0, 
      role: json['role'] ?? 'Atleta',
    );
  }
}
