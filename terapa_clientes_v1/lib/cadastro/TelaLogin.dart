// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:terapa_clientes_v1/componentes/funcoes.dart' show irPara;
import 'package:terapa_clientes_v1/cadastro/cadastrousuario.dart'
    show TelaCadastroUsuario;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:terapa_clientes_v1/usuario/inicio.dart';
// import 'package:terapa_clientes_v1/services/auth_service.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});
  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  bool _loading = false;
  String? _erro;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      irPara(context, TelaInicioUsuario());
    } on FirebaseAuthException catch (e) {
      setState(() {
        _erro = e.message;
        print(_erro);
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              SizedBox(height: currentHeight * 0.1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Image.asset("imagens/terapa+.png"),
                ),
              ),
              SizedBox(height: currentHeight * 0.065),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                    hintText: "Email",
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(height: currentHeight * 0.065),
              // Substitua passwordField pelo TextField com o controlador
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    filled: true,
                    contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                    hintText: "Senha",
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: currentHeight * 0.065),
              // Substitua buttonLogin pelo botão que chama _handleLogin
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: Text('Entrar'),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Não tem uma conta?"),
                  TextButton(
                    onPressed: () {
                      irPara(context, TelaCadastroUsuario());
                    },
                    child: Text(
                      "Cadastre-se",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 51, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: currentHeight * 0.2),
            ],
          ),
        ),
      ),
    );
  }
}
