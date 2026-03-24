class UserModel {
  final String nome;
  final String email;
  final String senha;
  final int nivel;
  final int xp;
  final String classe;

  UserModel({
    required this.nome,
    required this.email,
    required this.senha,
    this.nivel = 1, // Padrão: nível 1
    this.xp = 0, // Padrão: 0 XP
    this.classe = "Recruta", // Padrão: Recruta
  });
}
