import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

///
/// Bouton d'action qui affiche un indicateur tant que `isLoading` est vrai.
/// Partagé par les écrans de connexion et d'inscription.
///
class ElevatedLoadingButton extends StatelessWidget {
  const ElevatedLoadingButton({
    Key? key,
    this.onPressed,
    required this.title,
    required this.isLoading,
    this.loadingWidget,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final String title;
  final ValueListenable<bool> isLoading;
  final Widget? loadingWidget;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (_, bool loading, __) {
              if (!loading) {
                return const SizedBox.shrink();
              }
              return loadingWidget ??
                  LoadingBouncingGrid.circle(
                    size: 20,
                    backgroundColor: Colors.white,
                  );
            },
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          Container()
        ],
      ),
    );
  }
}
