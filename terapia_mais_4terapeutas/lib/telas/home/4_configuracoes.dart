import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:terapia_mais_4terapeutas/default/funcoes.dart';
import 'package:terapia_mais_4terapeutas/telas/login/tela_login.dart';
import 'package:terapia_mais_4terapeutas/telas/login/teste.dart';
import 'package:terapia_mais_4terapeutas/telas/perfil/perfil.dart';

class TelaConfiguracoes extends StatefulWidget {
  const TelaConfiguracoes({super.key});

  @override
  State<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  bool _notificacoes = false;
  bool _temaEscuro = false;
  bool _isAdmin = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _verificarAdmin();
  }

  Future<void> _verificarAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_userId)
          .get();
      setState(() {
        _isAdmin = doc.data()?['admin'] == true;
      });
    }
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
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Notificações'),
            subtitle: Text('Receber notificações do app'),
            value: _notificacoes,
            activeColor: Colors.black, // cor do botão quando ativado
            inactiveThumbColor:
                Colors.grey.shade400, // cor do botão quando desativado
            inactiveTrackColor:
                Colors.grey.shade300, // cor da trilha quando desativado
            onChanged: (val) {
              setState(() => _notificacoes = val);
            },
          ),
          SwitchListTile(
            title: Text('Tema escuro'),
            subtitle: Text('Ativar modo escuro'),
            value: _temaEscuro,
            activeColor: Colors.black,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade300,
            onChanged: (val) {
              setState(() => _temaEscuro = val);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.add_a_photo),
            title: Text('Editar perfil'),
            subtitle: Text('Troque as informações do seu perfil'),
            onTap: irPara(context, TelaEditarPerfil()),
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
              irPara(context, Telalogin(), apagarAnterior: true)();
            },
          ),
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: ListTile(
                  leading: Icon(
                    Icons.admin_panel_settings,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Painel Administrativo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Acesso exclusivo para administradores'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    irPara(context, LoginTeste())();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
