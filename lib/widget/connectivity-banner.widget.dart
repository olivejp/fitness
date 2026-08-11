import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/l10n/l10n.dart';
import 'package:fitnc_user/service/connectivity.service.dart';
import 'package:flutter/material.dart';

///
/// Bandeau affiché en haut de l'application quand la connexion est perdue.
///
/// C'est le seul consommateur de [ConnectivityService] : sans lui, le service
/// n'aurait aucun lecteur et l'information ne servirait à rien.
///
/// Placé dans le `builder` de `MaterialApp`, donc au-dessus du `Navigator` : le
/// bandeau reste visible quel que soit l'écran affiché.
///
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: di<ConnectivityService>().isConnected,
      // `child` est passé à part : il ne dépend pas de l'état de la connexion
      // et n'a donc pas à être reconstruit à chaque changement.
      child: child,
      builder: (BuildContext context, bool isConnected, Widget? child) {
        return Column(
          children: <Widget>[
            if (!isConnected) const _OfflineBar(),
            Expanded(child: child!),
          ],
        );
      },
    );
  }
}

class _OfflineBar extends StatelessWidget {
  const _OfflineBar();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.wifi_off, size: 18, color: colors.onErrorContainer),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  context.l10n.noConnection,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: colors.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
