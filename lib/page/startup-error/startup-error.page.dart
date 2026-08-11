import 'package:fitnc_user/l10n/l10n.dart';
import 'package:flutter/material.dart';

///
/// Écran affiché quand l'initialisation de Firebase échoue.
///
/// Sans lui, l'échec se traduisait par un écran blanc muet : aucun message,
/// aucune trace, et une cause impossible à deviner (le plus souvent l'absence
/// de GoogleService-Info.plist sur iOS ou de google-services.json sur Android).
///
class StartupErrorPage extends StatelessWidget {
  const StartupErrorPage({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.cloud_off_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  context.l10n.startupFailed,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.startupFailedDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.l10n.retry),
                ),
                const SizedBox(height: 32),
                // Détail technique : replié par défaut, mais accessible. C'est
                // ce qui manquait le plus pour diagnostiquer un démarrage raté.
                ExpansionTile(
                  title: Text(
                    'Détail technique',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SelectableText(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
