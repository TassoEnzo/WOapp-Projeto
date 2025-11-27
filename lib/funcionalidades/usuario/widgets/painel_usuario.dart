import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../usuario/widgets/atualizar_dados.dart';

class PainelUsuario {
  static void abrir(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final user = FirebaseAuth.instance.currentUser;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PainelUsuario',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: width * 0.6,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E3D3C),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("usuarios")
                      .doc(user?.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final dados =
                        snapshot.data!.data() as Map<String, dynamic>? ?? {};

                    final nome = dados["nome"] ?? "Usuário";
                    final email = dados["email"] ?? "";
                    final fotoBase64 = dados["fotoBase64"];

                    ImageProvider avatar;
                    if (fotoBase64 != null) {
                      avatar = MemoryImage(base64Decode(fotoBase64));
                    } else {
                      avatar = const AssetImage('assets/images/avatar.png');
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: avatar,
                                backgroundColor: Colors.grey[700],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Bem-vindo, $nome 👋",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        const Divider(color: Colors.white24),

                        ListTile(
                          leading: const Icon(Icons.edit, color: Colors.white),
                          title: const Text(
                            'Atualizar Dados',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.pop(context);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AtualizarDadosPagina(
                                  nomeAtual: nome,
                                  emailAtual: email,
                                ),
                              ),
                            );
                          },
                        ),

                        const Spacer(),

                        ListTile(
                          leading: const Icon(Icons.exit_to_app, color: Colors.red),
                          title: const Text(
                            'Sair',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () async {
                            Navigator.pop(context);

                            final navigator = Navigator.of(context);

                            await FirebaseAuth.instance.signOut();

                            navigator.pushNamedAndRemoveUntil(
                              '/inicial',
                              (_) => false,
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      },
    );
  }
}
