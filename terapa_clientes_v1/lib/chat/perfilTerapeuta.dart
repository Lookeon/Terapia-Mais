import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:terapa_clientes_v1/chat/chatDEVDD.dart';
import 'package:terapa_clientes_v1/componentes/funcoes.dart' show irPara;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class TelaVerTerapeuta extends StatefulWidget {
  final String nomeUsuario;
  final String fotoUsuario;
  final String nomeDoChat;

  const TelaVerTerapeuta({
    super.key,
    required this.nomeUsuario,
    required this.fotoUsuario,
    required this.nomeDoChat,
  });

  @override
  State<TelaVerTerapeuta> createState() => _TelaVerTerapeutaState();
}

class _TelaVerTerapeutaState extends State<TelaVerTerapeuta> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
  }

  String gerarChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  Future<String> criarOuPegarChat(
    String uidPaciente,
    String uidTerapeuta,
  ) async {
    final chatId = gerarChatId(uidPaciente, uidTerapeuta);
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    final doc = await chatRef.get();
    if (!doc.exists) {
      await chatRef.set({
        'usuarios': [uidPaciente, uidTerapeuta],
        'criadoEm': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  ImageProvider<Object> _getImagem(String foto) {
    if (foto.isEmpty) return const AssetImage('imagens/deni.jpeg');
    try {
      final bytes = base64Decode(foto);
      return MemoryImage(bytes);
    } catch (e) {
      return NetworkImage(foto);
    }
  }

  Future<void> _marcarSessao(String uidPaciente, String uidTerapeuta) async {
    DateTime? dataSelecionada = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (dataSelecionada == null) return;

    final terapeutaDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uidTerapeuta)
        .get();
    final rawHorarios = (terapeutaDoc.data() ?? {})['horarios'];

    String _normalize(String s) {
      final withoutDiacritics = s
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('à', 'a')
          .replaceAll('ã', 'a')
          .replaceAll('â', 'a')
          .replaceAll('é', 'e')
          .replaceAll('ê', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ô', 'o')
          .replaceAll('õ', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ç', 'c');
      return withoutDiacritics.replaceAll(RegExp(r'[^a-z0-9]'), '');
    }

    String diaSemana = DateFormat(
      'EEEE',
      'pt_BR',
    ).format(dataSelecionada).toLowerCase();
    final variations = <String>{
      diaSemana,
      diaSemana.replaceAll('-feira', ''),
      diaSemana.split('-').first,
      diaSemana.split(' ').first,
      if (diaSemana.isNotEmpty)
        '${diaSemana[0].toUpperCase()}${diaSemana.substring(1)}',
    }.map((s) => _normalize(s)).where((s) => s.isNotEmpty).toList();

    debugPrint('[_marcarSessao] rawHorarios: $rawHorarios');
    debugPrint('[_marcarSessao] variations(normalized): $variations');

    dynamic horariosRawValue;
    String? foundKey;

    if (rawHorarios is Map) {
      for (final entry in rawHorarios.entries) {
        final k = entry.key.toString();
        final nk = _normalize(k);
        if (variations.contains(nk)) {
          horariosRawValue = entry.value;
          foundKey = k;
          break;
        }
      }

      if (horariosRawValue == null && variations.isNotEmpty) {
        final v0 = variations.first;
        if (v0.length >= 2) {
          for (final entry in rawHorarios.entries) {
            final nk = _normalize(entry.key.toString());
            if (nk.startsWith(
              v0.substring(0, v0.length >= 3 ? 3 : v0.length),
            )) {
              horariosRawValue = entry.value;
              foundKey = entry.key.toString();
              break;
            }
          }
        }
      }

      if (horariosRawValue == null && variations.isNotEmpty) {
        for (final entry in rawHorarios.entries) {
          final nk = _normalize(entry.key.toString());
          if (variations.any((varn) => nk.contains(varn))) {
            horariosRawValue = entry.value;
            foundKey = entry.key.toString();
            break;
          }
        }
      }
    } else if (rawHorarios is List) {
      try {
        final idx = dataSelecionada.weekday - 1;
        if (idx >= 0 && idx < rawHorarios.length) {
          horariosRawValue = rawHorarios[idx];
          foundKey = 'index:$idx';
        }
      } catch (_) {}
    }

    horariosRawValue ??= (rawHorarios is Map
        ? (rawHorarios['Segunda'] ?? rawHorarios['segunda'])
        : null);

    List horarios = [];
    if (horariosRawValue == null) {
      final dataMap = (terapeutaDoc.data() ?? {}) as Map<String, dynamic>;
      for (final key in ['horariosDisponiveis', 'agenda', 'disponibilidade']) {
        if (dataMap.containsKey(key) && dataMap[key] != null) {
          final v = dataMap[key];
          if (v is List) {
            horarios = v;
          } else if (v is Map && v.containsKey(diaSemana)) {
            horarios = v[diaSemana];
          } else if (v is Map) {
            for (final val in v.values) {
              if (val is List)
                horarios.addAll(val);
              else if (val is String)
                horarios.addAll(
                  val
                      .split(RegExp(r'[;,]'))
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty),
                );
              else
                horarios.add(val);
            }
          } else if (v is String) {
            horarios = v
                .split(RegExp(r'[;,]'))
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
          }
          if (horarios.isNotEmpty) break;
        }
      }
    } else {
      if (horariosRawValue is List) {
        horarios = horariosRawValue;
      } else if (horariosRawValue is Map) {
        horarios = horariosRawValue.values.toList();
      } else if (horariosRawValue is String) {
        horarios = horariosRawValue
            .split(RegExp(r'[;,]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else {
        horarios = [horariosRawValue];
      }
    }

    if (horarios.isEmpty && rawHorarios is Map) {
      for (final entry in rawHorarios.entries) {
        final v = entry.value;
        if (v is List)
          horarios.addAll(v);
        else if (v is Map)
          horarios.addAll(v.values);
        else if (v is String)
          horarios.addAll(
            v
                .split(RegExp(r'[;,]'))
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty),
          );
      }
    }

    debugPrint('[_marcarSessao] foundKey: $foundKey');
    debugPrint('[_marcarSessao] horariosRawValue: $horariosRawValue');
    debugPrint('[_marcarSessao] horarios (final): $horarios');

    if (horarios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nenhum horário disponível em ${DateFormat('EEEE', 'pt_BR').format(dataSelecionada)}.',
          ),
        ),
      );
      return;
    }

    String? horarioSelecionado = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Escolha o horário em ${DateFormat('dd/MM/yyyy').format(dataSelecionada)}',
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: horarios.map<Widget>((h) {
                if (h is Map) {
                  final inicio = (h['inicio'] ?? h['start'] ?? '').toString();
                  final fim = (h['fim'] ?? h['end'] ?? '').toString();
                  final textoHorario = (inicio.isNotEmpty && fim.isNotEmpty)
                      ? '$inicio - $fim'
                      : h.values.join(' - ');
                  return ListTile(
                    title: Text(textoHorario),
                    onTap: () => Navigator.pop(context, textoHorario),
                  );
                } else {
                  final texto = h?.toString() ?? '';
                  return ListTile(
                    title: Text(texto),
                    onTap: () => Navigator.pop(context, texto),
                  );
                }
              }).toList(),
            ),
          ),
        );
      },
    );

    if (horarioSelecionado == null) return;

    final exists = await FirebaseFirestore.instance
        .collection('eventos')
        .where('uidTerapeuta', isEqualTo: uidTerapeuta)
        .where(
          'data',
          isEqualTo: DateFormat('yyyy-MM-dd').format(dataSelecionada),
        )
        .where('horario', isEqualTo: horarioSelecionado)
        .get();

    if (exists.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Já existe uma sessão marcada com o terapeuta nessa data e horário!',
          ),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('eventos').add({
      'uidPaciente': uidPaciente,
      'uidTerapeuta': uidTerapeuta,
      'data': DateFormat('yyyy-MM-dd').format(dataSelecionada),
      'horario': horarioSelecionado,
      'criadoEm': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sessão marcada em ${DateFormat('dd/MM/yyyy').format(dataSelecionada)} às $horarioSelecionado!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uidPaciente = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('usuarios')
          .where('nome', isEqualTo: widget.nomeUsuario)
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Terapeuta não encontrado.')),
          );
        }

        final terapeutaData =
            snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final descricao =
            terapeutaData['descricao'] ?? 'O terapeuta não possui descrição.';
        final uidTerapeuta =
            terapeutaData['uid'] ?? snapshot.data!.docs.first.id;

        return Scaffold(
          backgroundColor: Colors.amber[50],
          appBar: AppBar(backgroundColor: Color.fromARGB(237, 108, 171, 124)),
          body: Center(
            heightFactor: 1.3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: _getImagem(widget.fotoUsuario),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.nomeUsuario,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      descricao,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () => _marcarSessao(uidPaciente, uidTerapeuta),
                      child: const Text('Marcar Sessão'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        backgroundColor: const Color.fromARGB(
                          158,
                          19,
                          130,
                          155,
                        ),
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: () async {
                        final chatId = await criarOuPegarChat(
                          uidPaciente,
                          uidTerapeuta,
                        );
                        irPara(
                          context,
                          TelaChatUnificada(
                            chatId: chatId,
                            uidOutroUsuario: uidTerapeuta,
                            nomeOutroUsuario: widget.nomeUsuario,
                            fotoOutroUsuario: widget.fotoUsuario,
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text("Iniciar Chat"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          158,
                          19,
                          130,
                          155,
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
