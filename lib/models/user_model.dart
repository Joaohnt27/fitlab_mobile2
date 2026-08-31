class UserModel {
  final int? id;
  String nome;
  String email;
  String senha;
  final String? estado;
  final String? cidade;
  final String? dtNascimento;
  final String? genero;
  final double? peso;
  final double? altura;
  final int nivel;
  final int xp;
  final String classe;
  String avatar;
  String bio;
  final int territorios;
  final int conquistas;
  final int streak;
  final int ranking;
  final String role;
  final Map<String, dynamic>? plano; 
  final String? cref; 
  final DateTime? ultimoLogin;
  final Map<String, dynamic>? experimento;
  final int? totalTreinos;
  final int? fitpoints;

  UserModel({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    this.estado,
    this.cidade,
    this.dtNascimento,
    this.genero,
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
    this.plano, 
    this.cref, 
    this.experimento,
    this.ultimoLogin,
    this.totalTreinos,
    this.fitpoints,
  });

  UserModel copyWith({
    int? id,
    String? nome,
    String? email,
    String? senha,
    String? estado,
    String? cidade,
    String? dtNascimento,
    String? genero,
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
    Map<String, dynamic>? plano, 
    String? cref, 
    Map<String, dynamic>? experimento,
    DateTime? ultimoLogin,
    int? totalTreinos,
    int? fitpoints,
  }) {
    return UserModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      estado: estado ?? this.estado,
      cidade: cidade ?? this.cidade,
      dtNascimento: dtNascimento ?? this.dtNascimento,
      genero: genero ?? this.genero,
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
      cref: cref ?? this.cref, 
      experimento: experimento ?? this.experimento,
      ultimoLogin: ultimoLogin ?? this.ultimoLogin,
      totalTreinos: totalTreinos ?? this.totalTreinos,
      fitpoints: fitpoints ?? this.fitpoints
    );
  }

  // Converte o objeto Dart para um mapa JSON (vai ser enviado para a API)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nome": nome,
      "email": email,
      "senha": senha,
      "peso": peso,
      "altura": altura,
      "estado": estado,
      "cidade": cidade,
      "dtNascimento": dtNascimento,
      "genero": genero,
      "role": role,
      "plano": plano, 
      "cref": cref, 
    };
  }

  // Cria um objeto Dart a partir de um JSON (Quando a API devolver os dados)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      avatar: json['fotoPerfil'] ?? "🧪",
      bio: json['bioUsuario'] ?? json['bio'] ?? "Olá! Sou um entusiasta do FitLab e estou aqui para experimentar novas rotinas de treino.",
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      senha: json['senha'] ?? '',
      xp: json['xp'] ?? json['xpAcumulado'] ?? 0,
      role: json['role'] ?? 'Atleta',
      plano: json['plano'] as Map<String, dynamic>?,
      fitpoints: json['fitpoints'] ?? 0,
      streak: json['streak'] ?? 0,
      totalTreinos: json['totalTreinos'] ?? 0,
      ranking: json['ranking'] ?? 0,
    );
  }
}
