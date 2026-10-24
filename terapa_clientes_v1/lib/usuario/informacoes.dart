import 'package:flutter/material.dart';
import 'package:terapa_clientes_v1/componentes/funcoes.dart';
import 'package:terapa_clientes_v1/componentes/widgets.dart' show userAppBar;
import 'package:terapa_clientes_v1/usuario/inicio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaInformacoes extends StatefulWidget {
  final String? nomeUsuario;
  final String? emailUsuario;
  String? senhaUsuario;
  final String? fotoUsuario;

  TelaInformacoes({
    super.key,
    required this.nomeUsuario,
    required this.emailUsuario,
    required this.senhaUsuario,
    this.fotoUsuario,
  });

  @override
  State<TelaInformacoes> createState() => _TelaInformacoesState();
}

class _TelaInformacoesState extends State<TelaInformacoes> {
  OverlayEntry? _overlayEntry;
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? senhaAtual;
  String? nomeAtual;
  String? emailAtual;
  String? bioAtual;
  bool isTerapeuta = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    bioAtual = null;
    isTerapeuta = false;
  }

  Future<void> _carregarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          nomeAtual = data['nome'] ?? "";
          emailAtual = data['email'] ?? "";
          senhaAtual = data['senha'] ?? "";
        });
      }
    }
  }

  Future<void> _salvarCampo(String campo, String valor) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
        campo: valor,
      });
      setState(() {
        if (campo == 'senha') senhaAtual = valor;
        if (campo == 'nome') nomeAtual = valor;
        if (campo == 'email') emailAtual = valor;
      });
    }
  }

  void _showOverlayCampo(BuildContext context, String campo, String label, String? valorAtual, TextEditingController controller) {
    if (campo == 'senha') {
      _showOverlaySenha(context);
      return;
    }
    final currentHeight = MediaQuery.of(context).size.height;
    controller.text = valorAtual ?? "";
    double opacity = 0.0;
    late StateSetter setLocalState;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.3),
          ),
          Positioned(
            top: currentHeight * 0.4,
            left: 50,
            right: 50,
            child: StatefulBuilder(
              builder: (context, setState) {
                setLocalState = setState;
                return AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration(milliseconds: 100),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade900
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Editar $label', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 12),
                          TextField(
                            controller: controller,
                            obscureText: label == "senha" ? true : false,
                            decoration: InputDecoration(
                              labelText: "Trocar $label",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _overlayEntry?.remove();
                                  _overlayEntry = null;
                                },
                                child: Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final novoValor = controller.text;
                                  await _salvarCampo(campo, novoValor);
                                  _overlayEntry?.remove();
                                  _overlayEntry = null;
                                },
                                child: Text('Salvar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(Duration(milliseconds: 50), () {
      setLocalState(() {
        opacity = 1.0;
      });
    });
  }

  void _showOverlaySenha(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email de redefinição de senha enviado para ${user.email!}')),
      );
    }
  }

  void _showOverlayNome(BuildContext context) {
    _showOverlayCampo(context, 'nome', 'nome', nomeAtual, _nomeController);
  }

  Future<void> _showOverlayEmail(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum usuário logado.')),
      );
      return;
    }

    final TextEditingController emailController = TextEditingController();

    final novoEmail = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar e-mail'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Digite o novo e-mail',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, emailController.text.trim());
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (novoEmail == null || novoEmail.isEmpty) return;

    try {
      await user.verifyBeforeUpdateEmail(novoEmail);

      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
        'email': novoEmail,
      });

      setState(() {
        emailAtual = novoEmail;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Um e-mail de verificação foi enviado para $novoEmail. '
            'Confirme pelo link antes que a troca seja concluída.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Future<void> _editarBioDialog() async {
    final TextEditingController bioController = TextEditingController(text: bioAtual ?? "");
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Bio'),
          content: TextField(
            controller: bioController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Escreva um pouco sobre você...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, bioController.text),
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        bioAtual = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.amber[50],
      resizeToAvoidBottomInset: false,
      appBar: userAppBar(context, "Dados pessoais"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 50,
            backgroundImage: (widget.fotoUsuario != null && widget.fotoUsuario!.isNotEmpty)
                ? AssetImage('imagens/adicionarFoto.webp') as ImageProvider
                : AssetImage('imagens/adicionarFoto.webp') as ImageProvider,
          ),
          const SizedBox(height: 16),
          Text(
            nomeAtual ?? "",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.person, size: 32),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      'Nome: ${nomeAtual ?? ""}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showOverlayNome(context);
                  },
                  icon: Icon(Icons.edit, size: 20),
                )
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.email, size: 32),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      "Email: ${emailAtual ?? ""}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showOverlayEmail(context);
                  },
                  icon: Icon(Icons.edit, size: 20),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && user.email != null) {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Email de redefinição de senha enviado para ${user.email!}')),
                );
              }
            },
            child: Text(
              "Redefinir senha",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: currentHeight * 0.035),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () {
                    irPara(context, TelaInicioUsuario(), fecharAnterior: true);
                  },
                  child: Text(
                    "Salvar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
