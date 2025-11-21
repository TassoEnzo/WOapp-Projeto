class MensagemTemplate {
  static String avisoAlteracaoDados({
    required String nome,
    required String email,
  }) {
    return '''
Olá $nome,

Detectamos uma atualização recente em sua conta WOApp.

Se foi você, não é necessário fazer mais nada.
Se não foi você, recomendamos que acesse sua conta e altere sua senha imediatamente.

📩 Conta: $email

Atenciosamente,
Equipe WOApp 🐾
    ''';
  }
}
