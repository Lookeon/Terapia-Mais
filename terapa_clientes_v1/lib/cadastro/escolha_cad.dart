import 'package:flutter/material.dart';
import 'package:terapa_clientes_v1/componentes/funcoes.dart' show irPara;
import 'package:terapa_clientes_v1/cadastro/cadastrousuario.dart';
import 'package:terapa_clientes_v1/cadastro/TelaLogin.dart' show TelaLogin;

class TelaEscolhaLogin extends StatefulWidget {
  const TelaEscolhaLogin({super.key});

  @override
  State<TelaEscolhaLogin> createState() => _TelaEscolhaLoginState();
}

class _TelaEscolhaLoginState extends State<TelaEscolhaLogin> {

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Image.asset("imagens/logo_terapa.png"),
              ),
              SizedBox(
                height: currentHeight*0.05,
              ),
            SizedBox(
              height: currentHeight*0.1,
              width: currentWidth*0.7,
              child: ElevatedButton(
                onPressed: (){
                  irPara(
                    context,
                    TelaCadastroUsuario()
                  );
                },
                child: Center(
                  child: Text(
                    "Não tenho cadastro",
                    style: TextStyle(
                      fontSize: currentWidth*0.05
                    ),
                  )
                )
              ),
            ),
            SizedBox(
              height: currentHeight*0.05,
            ),
            SizedBox(
              height: currentHeight*0.1,
              width: currentWidth*0.7,
              child: ElevatedButton(
                onPressed: (){
                  irPara(
                    context,
                    TelaLogin()
                  );
                },
                child: Center(
                  child: Text(
                    "Já tenho cadastro",
                    style: TextStyle(
                      fontSize: currentWidth*0.05
                    ),
                  )
                )
              ),
            ),
            SizedBox(
              height: currentHeight*0.05,
            ),
          ],
          )
        ),
    );
  }
}