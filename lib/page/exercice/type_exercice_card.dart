import 'package:flutter/material.dart';

// TODO peut être supprimer ce widget s'il sert plus à rien.
class TypeExerciseCard extends StatelessWidget {
  const TypeExerciseCard({super.key, required this.child, required this.onTap, this.title});

  final Widget? title;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (title != null) title!,
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(const Size.square(100)),
              child: Center(
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
