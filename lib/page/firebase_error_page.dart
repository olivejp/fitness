import 'package:flutter/material.dart';

class FirebaseErrorPage extends StatelessWidget {
  const FirebaseErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Center(
        child: Text("Firebase n'a pas été initialisé correctement."),
      ),
    );
  }
}
