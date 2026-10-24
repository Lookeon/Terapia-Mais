import 'package:flutter/material.dart';
import 'package:terapa_clientes_v1/componentes/widgets.dart';
import 'package:terapa_clientes_v1/chat/chat.dart';
import 'package:terapa_clientes_v1/usuario/home.dart' show TelaHomeUsuario;
import 'package:terapa_clientes_v1/usuario/perfil.dart';
import 'package:terapa_clientes_v1/usuario/pesquisa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class TelaInicioUsuario extends StatefulWidget {
  const TelaInicioUsuario({super.key});

  @override
  State<TelaInicioUsuario> createState() => _TelaInicioUsuarioState();
}

class _TelaInicioUsuarioState extends State<TelaInicioUsuario> {
  int indexTela = 0;
  late PageController _pageController;

  String? nomeUsuario;
  String? fotoUsuario;
  String? emailUsuario;
  String? senhaUsuario;
  bool isTerapeuta = false;
  String? _userId;
  bool isAdmin = false;
  
  @override
  void initState() {
    super.initState();
    nomeUsuario = "";
    fotoUsuario = null;
    emailUsuario = "";
    senhaUsuario = "";
    _pageController = PageController(initialPage: indexTela);
    _carregarNomeUsuario();
  }

  ImageProvider<Object> _imageProviderFromString(String? foto) {
    if (foto == null || foto.isEmpty) {
      return const AssetImage('imagens/adicionarFoto.webp');
    }

    try {
      final bytes = base64Decode(foto);
      return MemoryImage(bytes);
    } catch (_) {}

    if (foto.startsWith('http')) {
      return NetworkImage(foto);
    }
    return AssetImage(foto);
  }

  Future<void> _carregarNomeUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        setState(() {
          if (data['nome'] != null) nomeUsuario = data['nome'];
          if (data['foto'] != null && data['foto'].toString().isNotEmpty) {
            fotoUsuario = data['foto'].toString();
          } else {
            fotoUsuario = null;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> get _telas => [
    TelaHomeUsuario(
      nomeUsuario: nomeUsuario ?? "",
      fotoUsuario: fotoUsuario ?? "imagens/adicionarFoto.webp",
    ),
    const TelaEscolhaChat(),
    TelaPesquisa(),
    const TelaConfiguracoes(),
  ];
  String get _tituloAppBar {
    if (indexTela == 0) {
      return nomeUsuario != null && nomeUsuario!.isNotEmpty
          ? "Bem vindo, $nomeUsuario!"
          : "Bem vindo!";
    } else if (indexTela == 1) {
      return "Conversas";
    } else if (indexTela == 2) {
      return "Pesquisa";
    } else if (indexTela == 3) {
      return nomeUsuario != null && nomeUsuario!.isNotEmpty
          ? "Configurações"
          : "Configurações";
    }
    return "";
  }

  bool get _isPesquisaTela => indexTela == 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: !_isPesquisaTela ? userAppBar(context, _tituloAppBar) : null,
      body: PageView(
        controller: _pageController,
        children: _telas,
        onPageChanged: (index) {
          setState(() {
            indexTela = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(158, 19, 130, 155),
              Color.fromARGB(237, 108, 171, 124),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: indexTela,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: const Color.fromARGB(255, 19, 130, 155),
          unselectedItemColor: const Color.fromARGB(255, 44, 44, 44),
          onTap: (index) {
            setState(() {
              indexTela = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 350),
                curve: Curves.ease,
              );
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "home",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: "conversas",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "pesquisa",
            ),
            BottomNavigationBarItem(
              icon: fotoUsuario == null
                  ? const Icon(Icons.person_add)
                  : CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 17,
                      backgroundImage: _imageProviderFromString(fotoUsuario),
                    ),
              label: "",
            ),
          ],
        ),
      ),
    );
  }
}
