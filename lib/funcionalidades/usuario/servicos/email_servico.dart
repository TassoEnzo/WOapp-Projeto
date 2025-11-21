import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mensagem_template.dart';

class EmailService {
  static const String _serviceId = 'seu_service_id';
  static const String _templateId = 'seu_template_id';
  static const String _userId = 'sua_chave_publica';

  static Future<void> enviarAvisoAlteracao({
    required String nome,
    required String email,
  }) async {
    final mensagem = MensagemTemplate.avisoAlteracaoDados(
      nome: nome,
      email: email,
    );

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _userId,
        'template_params': {
          'user_email': email,
          'user_name': nome,
          'message': mensagem,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao enviar e-mail: ${response.body}');
    }
  }
}
