import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '/../funcionalidades/usuario/servicos/mensagem_template.dart';

class AtualizarDadosControlador extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Atualiza os dados do usuário e envia o e-mail de aviso.
  Future<void> atualizarDados({
    required String nome,
    required String novoEmail,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      // Atualiza no Firestore
      await _firestore.collection('usuarios').doc(user.uid).update({
        'nome': nome,
        'email': novoEmail,
      });

      // Atualiza o e-mail de autenticação (seguro, exige verificação)
      await user.verifyBeforeUpdateEmail(novoEmail);

      // Envia o e-mail de aviso
      await _enviarEmailAviso(nome, novoEmail);
    } catch (e) {
      throw Exception("Erro ao atualizar dados: $e");
    }
  }

  /// Simula o envio de e-mail (aqui usaria o backend real)
  Future<void> _enviarEmailAviso(String nome, String email) async {
    final corpo = MensagemTemplate.avisoAlteracaoDados(
      nome: nome,
      email: email,
    );

    try {
      // Simulação de envio
      await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        body: {
          "to": email,
          "subject": "Aviso de alteração de dados - WOApp",
          "message": corpo,
        },
      );
    } catch (e) {
      debugPrint("Falha ao enviar e-mail: $e");
    }
  }
}