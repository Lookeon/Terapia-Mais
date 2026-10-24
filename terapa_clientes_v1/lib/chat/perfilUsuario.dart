import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class TelaEditarPerfil extends StatefulWidget {
  const TelaEditarPerfil({super.key});

  @override
  State<TelaEditarPerfil> createState() => _TelaEditarPerfilState();
}

class _TelaEditarPerfilState extends State<TelaEditarPerfil> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _descricaoController = TextEditingController();

  File? _imagemSelecionada;
  Uint8List? _imagemSelecionadaWeb;
  String? _fotoBase64;

  final _picker = ImagePicker();
  bool _loading = false;

  User? get _usuarioAtual => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    if (_usuarioAtual == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(_usuarioAtual!.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nomeController.text = data['nome'] ?? '';
        _emailController.text = data['email'] ?? '';
        _descricaoController.text = data['descricao'] ?? '';
        _fotoBase64 = data['foto'];
      });
    }
  }

  Future<void> _selecionarFoto() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _imagemSelecionadaWeb = result.files.single.bytes!;
        });
      }
    } else {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _imagemSelecionada = File(pickedFile.path);
        });
      }
    }
  }

  Uint8List _compactarImagem(Uint8List bytes) {
    final image = img.decodeImage(bytes)!;
    final resized = img.copyResize(image, width: 600);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 70));
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      String? fotoString = _fotoBase64;

      if (_imagemSelecionadaWeb != null) {
        final compactada = _compactarImagem(_imagemSelecionadaWeb!);
        fotoString = base64Encode(compactada);
        _imagemSelecionadaWeb = null;
      } else if (_imagemSelecionada != null) {
        final bytes = await _imagemSelecionada!.readAsBytes();
        final compactada = _compactarImagem(bytes);
        fotoString = base64Encode(compactada);
        _imagemSelecionada = null;
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_usuarioAtual!.uid)
          .set({
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'foto': fotoString ?? '',
      }, SetOptions(merge: true));

      if (_usuarioAtual!.email != _emailController.text.trim()) {
        await _usuarioAtual!.verifyBeforeUpdateEmail(_emailController.text.trim());
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Perfil atualizado!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao salvar perfil: $e')));
      print('Erro ao salvar perfil: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _trocarSenha() async {
    if (_usuarioAtual == null) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _usuarioAtual!.email!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de troca de senha enviado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  ImageProvider<Object>? _getImagemPerfil() {
    if (_imagemSelecionadaWeb != null) {
      return MemoryImage(_imagemSelecionadaWeb!);
    } else if (_imagemSelecionada != null) {
      return FileImage(_imagemSelecionada!) as ImageProvider;
    } else if (_fotoBase64 != null && _fotoBase64!.isNotEmpty) {
      return MemoryImage(base64Decode(_fotoBase64!));
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(158, 19, 130, 155),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _selecionarFoto,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _getImagemPerfil(),
                        child: _getImagemPerfil() == null
                            ? const Icon(Icons.add_a_photo, size: 40)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Digite seu nome' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Digite seu email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _trocarSenha,
                      child: const Text('Trocar senha', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _salvarPerfil,
                      child: const Text('Salvar alterações', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
