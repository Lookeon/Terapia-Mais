import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:terapa_clientes_v1/chat/chatDEVDD.dart';

class TelaEscolhaChat extends StatefulWidget {
  const TelaEscolhaChat({super.key});

  @override
  State<TelaEscolhaChat> createState() => _TelaEscolhaChatState();
}

class _TelaEscolhaChatState extends State<TelaEscolhaChat> {
  // Converte uma string que pode ser base64 ou URL para ImageProvider.
  ImageProvider? _imageProviderFromString(String? foto) {
    if (foto == null || foto.isEmpty) return null;
    try {
      final bytes = base64Decode(foto);
      return MemoryImage(bytes);
    } catch (_) {
      return NetworkImage(foto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUser = authSnapshot.data;
          if (currentUser == null) {
            return const Center(child: Text('Usuário não autenticado.'));
          }

          final uidTerapeuta = currentUser.uid;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('usuarios', arrayContains: uidTerapeuta)
                .orderBy('criadoEm', descending: true)
                .snapshots(),
            builder: (context, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (chatSnapshot.hasError) {
                return Center(
                  child: Text('Erro ao carregar chats: ${chatSnapshot.error}'),
                );
              }

              final chats = chatSnapshot.data?.docs ?? [];
              if (chats.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum chat encontrado.\nOs chats aparecerão quando forem iniciados.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final chatData = chat.data() as Map<String, dynamic>;
                  final String chatId = chat.id;
                  final List usuarios = chatData['usuarios'] ?? [];

                  // Encontrar outro UID
                  final outroUid = usuarios.firstWhere(
                    (u) => u != uidTerapeuta,
                    orElse: () => null,
                  );

                  if (outroUid == null) {
                    return const SizedBox();
                  }

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(outroUid)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      String nomeOutroUsuario = 'Usuário';
                      String fotoOutroUsuario = '';

                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        final data =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        nomeOutroUsuario = data['nome'] ?? 'Usuário';
                        fotoOutroUsuario =
                            data.containsKey('foto') &&
                                data['foto'] != null &&
                                data['foto'].toString().isNotEmpty
                            ? data['foto']
                            : '';
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SizedBox(
                          height: 92,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  _imageProviderFromString(fotoOutroUsuario),
                              backgroundColor: Colors.grey,
                              child: _imageProviderFromString(fotoOutroUsuario) ==
                                      null
                                  ? const Icon(
                                      Icons.person,
                                      size: 34,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            title: Text(
                              'Chat com $nomeOutroUsuario',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TelaChatUnificada(
                                    chatId: chatId,
                                    nomeOutroUsuario: nomeOutroUsuario,
                                    fotoOutroUsuario: fotoOutroUsuario,
                                    uidOutroUsuario: outroUid,
                                  ),
                                ),
                              );
                            },
                          ),
                        ));
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
