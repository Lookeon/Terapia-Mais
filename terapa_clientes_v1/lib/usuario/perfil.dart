import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:terapa_clientes_v1/cadastro/escolha_cad.dart';
import 'package:terapa_clientes_v1/chat/perfilUsuario.dart';
import 'package:terapa_clientes_v1/componentes/funcoes.dart';

class TelaConfiguracoes extends StatefulWidget {
  const TelaConfiguracoes({super.key});

  @override
  State<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  bool _notificacoes = false;
  bool _temaEscuro = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _salvarPreferencias() async {
    await FirebaseFirestore.instance
        .collection('preferencias')
        .doc(_userId ?? 'usuario_demo')
        .set({'notificacoes': _notificacoes, 'temaEscuro': _temaEscuro});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Preferências salvas!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Notificações'),
            subtitle: Text('Receber notificações do app'),
            value: _notificacoes,
            onChanged: (val) {
              setState(() => _notificacoes = val);
            },
          ),
          SwitchListTile(
            title: Text('Tema escuro'),
            subtitle: Text('Ativar modo escuro'),
            value: _temaEscuro,
            onChanged: (val) {
              setState(() => _temaEscuro = val);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.add_a_photo),
            title: Text('Editar perfil'),
            subtitle: Text('Troque as informações do seu perfil'),
            onTap: () {
              irPara(context, TelaEditarPerfil());
            },
          ),
          ListTile(
            leading: Icon(Icons.save, color: Theme.of(context).primaryColor),
            title: Text('Salvar preferências'),
            subtitle: Text('Salvar configurações no servidor'),
            onTap: _salvarPreferencias,
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Sair'),
            subtitle: Text('Fazer logout da conta'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              irPara(context, TelaEscolhaLogin(), fecharAnterior: true);
            },
          ),
        ],
      ),
    );
  }
}
