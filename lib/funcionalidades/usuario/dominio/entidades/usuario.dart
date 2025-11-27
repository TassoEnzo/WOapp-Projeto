class Usuario {
  final String id;
  final String nome;
  final String email;
  final String? fotoUrl;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.fotoUrl,
  });
}
