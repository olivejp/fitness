import 'package:flutter/material.dart';

class NetworkImageExerciseChoice extends StatelessWidget {
  const NetworkImageExerciseChoice({
    super.key,
    required this.imageUrl,
    this.radius = 25,
    this.height = 30,
    this.width = 30,
  });

  final String? imageUrl;
  final double radius;
  final double height;
  final double width;

  Widget _getDefaultErrorImage(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = (imageUrl != null)
        ? Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, loadingProgress) {
              return (loadingProgress != null) ? _getDefaultErrorImage(context) : child;
            },
            errorBuilder: (context, error, stackTrace) => _getDefaultErrorImage(context),
          )
        : _getDefaultErrorImage(context);

    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), color: Theme.of(context).primaryColor),
      child: child,
    );
  }
}
