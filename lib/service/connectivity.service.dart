import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

///
/// Surveille l'état de la connexion réseau.
///
/// Le service était enregistré dans `di` mais jamais résolu : personne
/// n'appelait `di<ConnectivityService>()`, donc il n'était jamais construit,
/// son écoute jamais démarrée et `isConnected` jamais alimenté. La détection de
/// connexion ne fonctionnait pas du tout. Il est désormais construit dès le
/// démarrage (`registerSingleton`, et non plus `registerLazySingleton`) et
/// affiché par [ConnectivityBanner].
///
class ConnectivityService {
  ConnectivityService() {
    // État initial, puis suivi des changements.
    Connectivity()
        .checkConnectivity()
        .then(_updateConnectivityStatus)
        .catchError((Object _) {
      // Une plateforme qui ne sait pas répondre ne doit pas faire croire à une
      // coupure : on reste sur l'hypothèse optimiste.
    });

    _subscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectivityStatus);
  }

  /// Optimiste au démarrage : tant que la première vérification n'a pas
  /// répondu, on n'affiche pas de bandeau « hors ligne » qui s'effacerait
  /// aussitôt à chaque lancement.
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(true);

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _disposed = false;

  /// Appelée par get_it quand le service est désenregistré.
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    isConnected.dispose();
  }

  // Depuis connectivity_plus 5, l'API renvoie une liste : un appareil peut être
  // relié à plusieurs réseaux à la fois (wifi + mobile, par exemple).
  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    // La vérification initiale est asynchrone : elle peut aboutir après la
    // libération du service, et écrire dans un notifier libéré lève.
    if (_disposed) {
      return;
    }
    isConnected.value = results.any((ConnectivityResult result) =>
        result != ConnectivityResult.none);
  }
}
