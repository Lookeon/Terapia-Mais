import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:terapa_clientes_v1/chat/perfilTerapeuta.dart';
import 'package:terapa_clientes_v1/componentes/funcoes.dart';

class TelaPesquisa extends StatefulWidget {
  const TelaPesquisa({super.key});

  @override
  State<TelaPesquisa> createState() => _TelaPesquisaState();
}

class _TelaPesquisaState extends State<TelaPesquisa> {
  String _termoPesquisa = '';
  String _filtroGenero = 'nada';
  String _palavraChave = '';
  String _filtroTema = 'todos';

  final TextEditingController _palavraChaveController = TextEditingController();

  final List<String> temasTerapia = [
    "Ansiedade",
    "Depressão",
    "Stress",
    "Transtorno de Humor",
    "Transtorno de Personalidade",
    "Transtorno Obsessivo-Compulsivo",
    "Transtorno de Alimentação",
    "Transtorno Dismórfico Corporal",
    "Autismo",
    "TDAH",
    "Transtorno de Sono",
    "Casal / Relacionamento",
    "Família",
    "Adolescente",
    "Criança",
    "Idoso",
    "Luto",
    "Autoestima",
    "Bullying",
    "Violência Doméstica",
    "Dependência Química",
    "Sexualidade",
    "Gênero",
    "Trauma / PTSD",
    "Ansiedade Social",
    "Fobia",
    "Problemas Escolares",
    "Estresse Profissional / Burnout",
    "Controle da Raiva",
    "Apoio LGBT+"
  ];

  @override
  void initState() {
    super.initState();
    _palavraChaveController.text = _palavraChave;
  }

  @override
  void dispose() {
    _palavraChaveController.dispose();
    super.dispose();
  }

  ImageProvider<Object> _getImagem(String? foto) {
    if (foto == null || foto.isEmpty) {
      return const AssetImage('imagens/default_avatar.png');
    }
    try {
      final decoded = base64Decode(foto);
      return MemoryImage(decoded);
    } catch (_) {
      return NetworkImage(foto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 19, 130, 155),
                  Color.fromARGB(255, 125, 207, 145),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              ),
              child: Center(
                child: Text(
                  'Filtros',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<String>(
                value: _filtroGenero,
                items: const [
                  DropdownMenuItem(
                    value: 'nada',
                    child: Text('Sem filtro de gênero'),
                  ),
                  DropdownMenuItem(value: 'feminino', child: Text('Feminino')),
                  DropdownMenuItem(
                    value: 'masculino',
                    child: Text('Masculino'),
                  ),
                  DropdownMenuItem(value: 'outro', child: Text('Outro')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Gênero',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() => _filtroGenero = value ?? 'nada');
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<String>(
                value: _filtroTema,
                items: [
                  const DropdownMenuItem(
                    value: 'todos',
                    child: Text('Todos os temas', overflow: TextOverflow.ellipsis),
                  ),
                  ...temasTerapia.map((t) => DropdownMenuItem(
                        value: t,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(t, overflow: TextOverflow.ellipsis),
                        ),
                      ))
                ],
                decoration: const InputDecoration(
                  labelText: 'Tema de terapia',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() => _filtroTema = value ?? 'todos');
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _palavraChaveController,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por especialização',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _palavraChave = value.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.amber[50],
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar terapeutas...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _termoPesquisa = value.toLowerCase();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .where('profissional', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum terapeuta encontrado.'));
          }

          final resultados = (snapshot.data?.docs ?? []).where((doc) {
            final data = (doc.data() as Map<String, dynamic>?) ?? <String, dynamic>{};

            final nome = (data['nome'] ?? '').toString().toLowerCase();
            final generoRaw = (data['genero'] ?? '').toString().trim();
            final genero = generoRaw.toLowerCase();
            final descricao = (data['descricao'] ?? '').toString().toLowerCase();

            final correspondePesquisa = nome.contains(_termoPesquisa);
            final correspondeGenero = _filtroGenero == 'nada' ||
                (_filtroGenero == 'outro'
                    ? {
                        'outro',
                        'outros',
                        'prefiro não dizer',
                        'prefiro nao dizer',
                        'não informado',
                        'nao informado',
                        'n/a',
                        'nao'
                      }.contains(genero)
                    : genero == _filtroGenero);
            final correspondePalavraChave =
                _palavraChave.isEmpty || descricao.contains(_palavraChave);

            bool correspondeTema() {
              if (_filtroTema == 'todos' || _filtroTema.isEmpty) return true;

              List<String> temasPerfil = [];
              final possible = ['temas', 'temasTerapia', 'temas_terapia', 'especializacoes', 'areas'];
              for (final key in possible) {
                if (!data.containsKey(key) || data[key] == null) continue;
                final raw = data[key];

                if (raw is List) {
                  temasPerfil = raw.map((e) => e.toString().toLowerCase()).toList();
                  break;
                } else if (raw is Iterable) {
                  temasPerfil = raw.map((e) => e.toString().toLowerCase()).toList();
                  break;
                } else if (raw is String) {
                  temasPerfil = raw
                      .split(RegExp(r'[;,]'))
                      .map((s) => s.trim().toLowerCase())
                      .where((s) => s.isNotEmpty)
                      .toList();
                  break;
                } else if (raw is Map) {
                  temasPerfil = raw.values.map((e) => e.toString().toLowerCase()).toList();
                  break;
                }
              }

              if (temasPerfil.isEmpty) {
                return descricao.contains(_filtroTema.toLowerCase());
              }

              return temasPerfil.contains(_filtroTema.toLowerCase());
            }

            return correspondePesquisa &&
                correspondeGenero &&
                correspondeTema() &&
                correspondePalavraChave;
          }).toList();

          if (resultados.isEmpty) {
            return const Center(child: Text('Nenhum terapeuta encontrado.'));
          }

          return ListView.builder(
            itemCount: resultados.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final terapeuta = resultados[index];
              final dados = terapeuta.data() as Map<String, dynamic>;
              final nome = dados['nome'] ?? 'Sem nome';
              final foto = dados['foto'] is String
                  ? dados['foto'] as String
                  : '';
              final genero = dados['genero'] ?? '';

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    irPara(
                      context,
                      TelaVerTerapeuta(
                        nomeUsuario: nome,
                        fotoUsuario: foto,
                        nomeDoChat: nome,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: _getImagem(foto),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nome,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                genero.isNotEmpty ? 'Gênero: $genero' : '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
