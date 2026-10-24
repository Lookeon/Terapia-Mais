import 'package:flutter/material.dart';

var _confirmPasswordController = TextEditingController();
var _pesquisaController = TextEditingController();

TextStyle style = TextStyle(
    fontFamily: "Montserrat", 
    fontSize: 20,
  );
    // color: Colors.black)


Widget pesquisaField(context){
  return FractionallySizedBox(
    widthFactor: 1,
    child: TextField(
      controller: _pesquisaController,
      obscureText: false,
      style: style.copyWith(
        fontSize: 15,
        color: Theme.of(context).colorScheme.primary
      ),
      decoration: InputDecoration(
        // fillColor: Theme.of(context).colorScheme.secondary,
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        // contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        hintText: "Pesquisa",
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
      ),
    ),
  );
}

Widget confirmPasswordField(BuildContext context) {
  return FractionallySizedBox(
    widthFactor: 0.7,
    child: TextField(
      controller: _confirmPasswordController,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
        // fillColor: Theme.of(context).colorScheme.secondary,
        filled: true,
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Confirmar Senha",
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
      ),
    ),
  );
}

Widget buttonLogin(BuildContext context) {
  return FractionallySizedBox(
    widthFactor: 0.6,
    child:ButtonTheme(
      child: ElevatedButton(
        onPressed: (){
          _confirmPasswordController.clear();
        },
        style: ButtonStyle(
          // backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
          minimumSize: WidgetStateProperty.all(Size(400,50)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32)
      )
    )
  ),
      child: Text("Login",
      textAlign: TextAlign.center,
      style: style.copyWith(color:Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)
        ),
      )
    )
  );
}


Widget buttonRegister(BuildContext context, Future<void> Function() onPressed, String Texto) {
  return FractionallySizedBox(
    widthFactor: 0.6,
    child: ButtonTheme(
      child: ElevatedButton(
        onPressed: () async {
          await onPressed();
          //_emailController.clear();
          //_passwordController.clear(); 
          //_nomeController.clear();
          //_confirmPasswordController.clear();
        },
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size(400,50)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32)
          ))
        ),
        child: Text(Texto,
          textAlign: TextAlign.center,
          style: style.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold)
        ),
      )
    )
  );
}

PreferredSizeWidget userAppBar(BuildContext context, String texto,) {
  return AppBar(
    automaticallyImplyLeading: false,
    title: Text(texto),
    centerTitle: true,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(158, 19, 130, 155),
            Color.fromARGB(237, 108, 171, 124)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
  );
}

Widget fotoDePerfil(String fotoUsuario, double currentWidth, StateSetter setState, {required VoidCallback onFotoAtualizada}) {
  return GestureDetector(
    onTap: () async {
      // Lógica para selecionar e atualizar a foto de perfil
      // Nenhuma lógica de diretório ou armazenamento local presente.
    },
    child: CircleAvatar(
      radius: currentWidth * 0.2,
      backgroundImage: AssetImage(fotoUsuario),
      backgroundColor: Colors.grey[300],
      child: Align(
        alignment: Alignment.bottomRight,
        child: CircleAvatar(
          radius: currentWidth * 0.06,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.camera_alt,
            color: Colors.grey[800],
            size: currentWidth * 0.06,
          ),
        ),
      ),
    ),
  );
}