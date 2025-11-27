import 'dart:io';
import 'dart:convert';

class FotoServico {
  static Future<String> converterParaBase64(File arquivo) async {
    try {
      final bytes = await arquivo.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception("Erro ao converter imagem: $e");
    }
  }
}