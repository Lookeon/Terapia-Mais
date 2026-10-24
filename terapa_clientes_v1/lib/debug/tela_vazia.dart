import 'package:flutter/material.dart';

class TelaVazia extends StatelessWidget {
  const TelaVazia({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Tela Vazia',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}