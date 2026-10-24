import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:terapa_clientes_v1/componentes/funcoes.dart' show irPara;
import 'package:terapa_clientes_v1/chat/perfilTerapeuta.dart';
import 'package:terapa_clientes_v1/usuario/pesquisa.dart';

class TelaHomeUsuario extends StatefulWidget {
  final String nomeUsuario;
  final String fotoUsuario;

  const TelaHomeUsuario({
    super.key,
    required this.nomeUsuario,
    required this.fotoUsuario,
  });

  @override
  State<TelaHomeUsuario> createState() => _TelaHomeUsuarioState();
}

class _TelaHomeUsuarioState extends State<TelaHomeUsuario> {
  List<Map<String, dynamic>> terapeutas = [];

  @override
  void initState() {
    super.initState();
    _buscarTerapeutas();
  }

  Future<void> _buscarTerapeutas() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('profissional', isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final docs = snapshot.docs.toList()..shuffle();
      final limitDocs = docs.length > 5 ? docs.sublist(0, 5) : docs;

      setState(() {
        terapeutas = limitDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'uid': doc.id,
            'nome': data['nome'] ?? 'Terapeuta',
            'foto': data['foto'] ?? '', 
            'endereco': data['endereco'] ?? 'Rua Desconhecida',
          };
        }).toList();
      });
    }
  }

  ImageProvider<Object> _getImagem(String foto) {
    if (foto.isEmpty) {
      return const AssetImage('imagens/adicionarFoto.webp');
    }
    try {
      final bytes = base64Decode(foto);
      return MemoryImage(bytes);
    } catch (e) {
      return NetworkImage(foto);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    final currentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: Column(
        children: [
          Container(
            width: currentWidth * 0.9,
            margin: const EdgeInsets.all(10),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: FractionallySizedBox(
                  child: Center(
                    child: Card(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(61, 19, 130, 155),
                              Color.fromARGB(104, 108, 171, 124),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          "Para começar, escolha um profissional encontrado em sua área",
                          style: TextStyle(fontSize: 24, fontFamily: "Verdana"),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: SizedBox(
              height: currentHeight * 0.48,
              child: ListView.builder(
                itemCount: terapeutas.length,
                itemBuilder: (context, index) {
                  final terapeuta = terapeutas[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(61, 19, 130, 155),
                            Color.fromARGB(104, 108, 171, 124),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: _getImagem(terapeuta['foto']),
                          radius: 24,
                        ),
                        title: Text(terapeuta['nome']),
                        subtitle: Text(terapeuta['endereco']),
                        trailing: const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                        ),
                        onTap: () {
                          irPara(
                            context,
                            TelaVerTerapeuta(
                              nomeUsuario: terapeuta['nome'],
                              fotoUsuario: terapeuta['foto'],
                              nomeDoChat: terapeuta['nome'],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: Offset(0, 8), 
                ),
              ],
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(61, 19, 130, 155),
                  Color.fromARGB(104, 108, 171, 124),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                irPara(context, TelaPesquisa());
              },
              child: const Text(
                "Procurando por algo expecífico? Aperte aqui!",
                style: TextStyle(fontSize: 16, fontFamily: "Verdana"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
