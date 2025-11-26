import 'package:flutter/material.dart';
import '../apresentacao/controladores/atualizar_dados_controlador.dart';

class AtualizarDadosPagina extends StatefulWidget {
  final String nomeAtual;
  final String emailAtual;

  const AtualizarDadosPagina({
    super.key,               // ✔ use_super_parameters resolvido
    required this.nomeAtual,
    required this.emailAtual,
  });

  @override
  State<AtualizarDadosPagina> createState() => _AtualizarDadosPageState();
}

class _AtualizarDadosPageState extends State<AtualizarDadosPagina> {
  final _formKey = GlobalKey<FormState>();
  final _controlador = AtualizarDadosControlador();

  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nomeAtual);
    _emailController = TextEditingController(text: widget.emailAtual);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _atualizar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await _controlador.atualizarDados(
        nome: _nomeController.text.trim(),
        novoEmail: _emailController.text.trim(),
      );

      // ✔ evita erro use_build_context_synchronously
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2B2A),
        elevation: 0,
        title: const Text("Atualizar Dados"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2F443F),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nome",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nomeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF1E2E2D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Digite seu nome' : null,
                ),
                const SizedBox(height: 20),

                const Text(
                  "E-mail",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF1E2E2D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Digite seu e-mail' : null,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _carregando ? null : _atualizar,
                    icon: const Icon(Icons.save),
                    label: _carregando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Salvar alterações"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}