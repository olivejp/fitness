import 'package:flutter/material.dart';

///
/// Bandes ambrées inclinées du fond des écrans d'authentification.
/// Utilisées par la connexion et l'inscription en présentation desktop.
///
class DecoSecondSlide extends StatelessWidget {
  const DecoSecondSlide({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..translate(MediaQuery.of(context).size.width - 850)
        ..add(Matrix4.skewX(-0.3)),
      child: Container(
        width: 20,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: <Color>[
              Colors.amber.shade700,
              Colors.amber.withAlpha(100),
            ],
          ),
        ),
      ),
    );
  }
}

class DecoFirstSlide extends StatelessWidget {
  const DecoFirstSlide({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..translate(MediaQuery.of(context).size.width - 800)
        ..add(Matrix4.skewX(-0.3)),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: <Color>[
              Colors.amber.shade700,
              Colors.amber.withAlpha(100),
            ],
          ),
        ),
      ),
    );
  }
}
