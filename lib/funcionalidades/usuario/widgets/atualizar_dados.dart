import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../servicos/permissoes_servico.dart';
import '../apresentacao/controladores/atualizar_dados_controlador.dart';

class AtualizarDadosPagina extends StatefulWidget {
  final String nomeAtual;
  final String emailAtual;

  const AtualizarDadosPagina({
    super.key,
    required this.nomeAtual,
    required this.emailAtual,
  });

  @override
  State<AtualizarDadosPagina> createState() => _AtualizarDadosPageState();
}

class _AtualizarDadosPageState extends State<AtualizarDadosPagina> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AtualizarDadosControlador>().carregarFotoInicial();
    });

    _nomeController = TextEditingController(text: widget.nomeAtual);
    _emailController = TextEditingController(text: widget.emailAtual);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selecionarFoto() async {
    final ok = await PermissoesServico.solicitarPermissoes();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permissões negadas!")),
      );
      return;
    }

    final ctrl = context.read<AtualizarDadosControlador>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SizedBox(
        height: 160,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.white),
              title: const Text("Escolher da Galeria",
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final img = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (img != null) {
                  await ctrl.atualizarFoto(
                    arquivo: File(img.path),
                    uid: FirebaseAuth.instance.currentUser!.uid,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text("Tirar Foto",
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final img = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (img != null) {
                  await ctrl.atualizarFoto(
                    arquivo: File(img.path),
                    uid: FirebaseAuth.instance.currentUser!.uid,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _atualizar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    final ctrl = context.read<AtualizarDadosControlador>();

    try {
      await ctrl.atualizarDados(
        nome: _nomeController.text.trim(),
        novoEmail: _emailController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dados atualizados com sucesso!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }

    if (mounted) setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AtualizarDadosControlador>();

    ImageProvider avatar;

    if (ctrl.fotoBase64 != null) {
      try {
        avatar = MemoryImage(base64Decode(ctrl.fotoBase64!));
      } catch (_) {
        avatar = const AssetImage("assets/images/avatar.png");
      }
    } else {
      avatar = const AssetImage("assets/images/avatar.png");
    }

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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2F443F),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _selecionarFoto,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: avatar,
                        ),
                      ),
                      Positioned(
                        right: -5,
                        bottom: -5,
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              size: 22, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),

                if (ctrl.carregandoFoto)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),

                const SizedBox(height: 20),

                _campo("Nome", _nomeController),
                const SizedBox(height: 20),

                _campo("E-mail", _emailController),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _carregando ? null : _atualizar,
                    icon: const Icon(Icons.save),
                    label: _carregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Salvar alterações"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _campo(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E2E2D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (v) => v == null || v.isEmpty
              ? "Digite seu $label"
              : null,
        ),
      ],
    );
  }
}
