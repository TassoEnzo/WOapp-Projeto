import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../servicos/foto_servico.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../servicos/mensagem_template.dart';

class AtualizarDadosControlador extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? fotoBase64;
  bool carregandoFoto = false;

  Future<void> carregarFotoInicial() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection("usuarios").doc(uid).get();
    fotoBase64 = doc.data()?["fotoBase64"];
    notifyListeners();
  }

  Future<void> atualizarDados({
    required String nome,
    required String novoEmail,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuário não autenticado.");

    await _firestore.collection('usuarios').doc(user.uid).update({
      'nome': nome,
      'email': novoEmail,
    });

    await user.verifyBeforeUpdateEmail(novoEmail);
    await _enviarEmailAviso(nome, novoEmail);
  }

  Future<void> atualizarFoto({
    required File arquivo,
    required String uid,
  }) async {
    try {
      carregandoFoto = true;
      notifyListeners();

      final base64 = await FotoServico.converterParaBase64(arquivo);

      await _firestore.collection('usuarios').doc(uid).update({
        'fotoBase64': base64,
      });

      fotoBase64 = base64;
      notifyListeners();
    } finally {
      carregandoFoto = false;
      notifyListeners();
    }
  }

  Future<void> _enviarEmailAviso(String nome, String email) async {
    final corpo = MensagemTemplate.avisoAlteracaoDados(
      nome: nome,
      email: email,
    );

    try {
      await http.post(
        Uri.parse("https://jsonplaceholder.typicode.com/posts"),
        body: {
          "to": email,
          "subject": "Aviso de alteração de dados - WOApp",
          "message": corpo,
        },
      );
    } catch (_) {}
  }
}