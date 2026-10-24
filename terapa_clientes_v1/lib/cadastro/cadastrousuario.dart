import 'package:flutter/material.dart';
import 'package:terapa_clientes_v1/componentes/widgets.dart';
import 'package:terapa_clientes_v1/componentes/funcoes.dart';
import 'package:terapa_clientes_v1/cadastro/TelaLogin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:terapa_clientes_v1/usuario/inicio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaCadastroUsuario extends StatefulWidget {
  const TelaCadastroUsuario({super.key});
  @override
  State<TelaCadastroUsuario> createState() => _TelaCadastroUsuarioState();
}

class _TelaCadastroUsuarioState extends State<TelaCadastroUsuario> {
  bool _loading = false;
  String? _erro;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();

  Future<void> _criarConta() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (cred.user != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(cred.user!.uid)
            .set({
              'email': _emailController.text.trim(),
              'nome': _nomeController.text.trim().isEmpty ? 'nome_padrao' : _nomeController.text.trim(),
            });
      }
      irPara(context, TelaInicioUsuario());
    } on FirebaseAuthException catch (e) {
      setState(() {
        _erro = e.message;
        print(_erro);
        print("ahhhhhhhhhhhhh");
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget emailField(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.7,
      child: TextField(
        controller: _emailController,
        obscureText: false,
        style: TextStyle(
          fontFamily: "Montserrat",
          fontSize: 20,
        ),
        decoration: InputDecoration(
          filled: true,
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Email",
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
        ),
      ),
    );
  }

  Widget passwordField(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.7,
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        style: TextStyle(
          fontFamily: "Montserrat",
          fontSize: 20,
        ),
        decoration: InputDecoration(
          filled: true,
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Senha",
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
        ),
      ),
    );
  }

  Widget nomeField(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.7,
      child: TextField(
        controller: _nomeController,
        obscureText: false,
        style: TextStyle(
          fontFamily: "Montserrat",
          fontSize: 20,
        ),
        decoration: InputDecoration(
          filled: true,
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Nome",
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: currentWidth,
        height: currentHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color.fromARGB(150, 19, 130, 155),
              Color.fromARGB(200, 108, 171, 124),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: currentHeight * 0.1),
              FractionallySizedBox(
                widthFactor: 0.8,
                child: Image.asset("imagens/logo_terapa.png"),
              ),
              SizedBox(height: currentHeight * 0.035),
              nomeField(context),
              SizedBox(height: currentHeight * 0.035),
              emailField(context),
              SizedBox(height: currentHeight * 0.035),
              passwordField(context),
              SizedBox(height: currentHeight * 0.035),
              confirmPasswordField(context),
              SizedBox(height: currentHeight * 0.035),
              ElevatedButton(onPressed: _criarConta, child: Text("Criar conta")),
              //buttonRegister(context, _criarConta, "Cadastrar"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Já tem uma conta?"),
                  TextButton(
                    onPressed: () {
                      irPara(context, TelaLogin());
                    },
                    child: Text(
                      "Logar",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 51, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: currentHeight * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
