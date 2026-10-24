import 'package:flutter/material.dart';
//import 'package:terapia_mais/telas/usuario/inicio.dart';

// Te odeio Navigator.push 💀
void irPara(BuildContext context, Widget tela, {bool fecharAnterior = false}) {
  if (fecharAnterior) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => tela,
      ),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => tela,
      ),
    );
  } 
}
