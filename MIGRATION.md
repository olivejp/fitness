# Refonte technique

Suivi des chantiers. **À mettre à jour à chaque étape.**

Les chantiers 1 à 6 constituaient la sortie de GetX, aujourd'hui terminée.
Les suivants portent sur la fiabilité et la structure du code.

## Décision

`get` porte aujourd'hui cinq rôles à lui seul. On le remplace par une brique
spécialisée par rôle, chacune activement maintenue :

| Rôle | Avant | Après |
|---|---|---|
| Injection / singletons | `Get.put` / `Get.find` / `Get.lazyPut` | **`get_it`** |
| Réactivité | `.obs` / `Obx` / `Rx*` | **`ValueNotifier` / `ChangeNotifier`** (Flutter natif) |
| Routage | `GetMaterialApp` / `GetPage` / `GetMiddleware` | **`go_router`** |
| i18n | `.tr` / `Translations` | **`gen-l10n`** (SDK Flutter, fichiers ARB) |
| Stockage local | `get_storage` | **`shared_preferences`** |

Motivation : `get` n'est pas abandonné mais accuse **1174 issues ouvertes** pour
une publication tous les six mois (v4.7.3, 2025-11-24). Ce n'est pas un sujet de
performance — l'`Obx` est déjà granulaire, et les problèmes réels du projet
(N+1 Firestore, fuites) venaient d'appels placés dans `build()`, pas de GetX.

### Modèle cible : page / notifier

- Un **service** est sans état d'écran, vit toute la session, et est enregistré
  dans `get_it` (`lib/di.dart`).
- Un **notifier** porte l'état d'un écran. Il est possédé par sa page
  (`StatefulWidget`), créé en `initState()`, libéré en `dispose()`.
  **Il n'est jamais enregistré dans `get_it`.**
- Une **page** est un `StatefulWidget` qui instancie son notifier et le passe à
  ses sous-widgets explicitement (constructeur), pas par résolution globale.

Ce modèle supprime par construction la classe de bugs corrigée en amont : plus
de `Get.put` en champ de `StatelessWidget`, plus de résolution implicite depuis
`build()`.

---

## État des chantiers

| # | Chantier | État | Sites |
|---|---|---|---|
| 1 | Injection → `get_it` | ✅ **Terminé** (soldé par le 3) | 64 |
| 2 | Routage → `go_router` | ✅ **Terminé** | 17 |
| 3 | Réactivité → notifiers | ✅ **Terminé** | 43 `Obx`, 34 `.obs`, 15 controllers |
| 4 | i18n → `gen-l10n` | ✅ **Terminé** | 90 `.tr` |
| 5 | Retrait de `get` du pubspec | ✅ **Terminé** | — |
| 6 | `get_storage` → `shared_preferences` | ✅ **Terminé** | 3 fichiers |
| 7 | Fiabilité du démarrage | ✅ **Terminé** | `main.dart` |
| 8 | Réintégration des packages internes | ✅ **Terminé** | 44 fichiers, 133 imports |
| 9 | Thème Material 3 | ✅ **Terminé** | 2 thèmes, 57 `primaryColor` |
| 10 | Bugs fonctionnels | ✅ **Terminé** | connectivité, `register()` |
| 11 | Firebase iOS configuré | ✅ **Terminé** | l'application démarre enfin |
| 12 | Suppression de `MyProgramsPage` | ✅ **Terminé** | 52 lignes |
| 13 | Retrait des abonnements et des coachs | ✅ **Terminé** | 13 fichiers, ~1 300 lignes |
| 14 | `storage-image.widget.dart` | ✅ **Terminé** | 351 → 118 lignes |
| 15 | Dépendances inutilisées | ✅ **Terminé** | 5 retirées, 9 résolues en moins |

**L'écosystème GetX est entièrement sorti du projet.** Ni `get` ni
`get_storage` dans les `pubspec.yaml`, aucun import résiduel.

---

## Chantier 1 — Injection → `get_it` ✅

### Fait

- `get_it: ^9.2.1` ajouté au projet et à `packages/fitness_domain`.
- `packages/fitness_domain/lib/di.dart` : expose le locator partagé `di`.
- `lib/di.dart` : `configureDependencies()`, appelé depuis `main()` avant
  `runApp`. Tous les services sont en **lazy singleton**, ce qui laisse `get_it`
  démêler l'ordre des dépendances (`FitnessUserService` → `PublishedProgrammeService`
  → `TrainersService`).
- **11 services** migrés, avec leur cycle de vie rendu explicite. `Get.put` /
  `Get.delete` déclenchaient `onInit` / `onClose` ; ces classes ne dérivent plus
  de `GetxService`, donc :
  - `AuthService`, `ConfigService`, `ConnectivityService`, `DarkModeController` :
    l'ancien `onInit()` est passé dans le constructeur.
  - `ConnectivityService` et `DarkModeController` déclarent un `dispose()`,
    branché sur le paramètre `dispose:` de `registerLazySingleton`.
  - `AbstractFirebaseCrudService` et `AbstractFirebaseSubcollectionCrudService`
    ne dérivent plus de `GetxService`.
- **47 sites** `Get.find<Service>()` → `di<Service>()`.
- `GetX<DisplayTypeService>` (login.page.dart) → `Obx` : le widget `GetX<T>`
  exige un `DisposableInterface`, incompatible avec un service simple. C'était
  le seul usage de ce widget dans le projet.

### Soldé par le chantier 3

Les 17 sites restants résolvaient des *controllers de page*, pas des services.
Ils ne sont volontairement **pas** entrés dans `get_it` : ils sont devenus des
notifiers possédés par leur page (voir chantier 3). Il ne reste donc aucun
`Get.put` / `Get.find` / `Get.delete` dans le projet.

### Point d'attention

`packages/fitness_domain/lib/service/abstract.service.dart:22` résout un service
par paramètre de type : `final X rootService = di<X>();`. Cela fonctionne (Dart
réifie les génériques) mais échoue à l'exécution si `X` n'est pas enregistré.
`UserSetService` en dépend pour atteindre `WorkoutInstanceService`.

---

## Chantier 2 — Routage → `go_router` ✅

`go_router: ^17.5.0`. Plus aucun symbole de routage GetX dans le projet.

### Fait

- `lib/router.dart` : `appRouter`, les 3 routes, la garde et les transitions.
- `GetMaterialApp` → `MaterialApp.router` (`main.dart`).
- 3 `GetPage` → `GoRoute`. La `Transition.rightToLeft` de login et sign-up est
  reproduite par un `CustomTransitionPage` + `SlideTransition`.
- `IsConnectedMiddleware` → `redirect` global (`_guardConnected`), avec une
  liste explicite de routes publiques. Les deux fichiers de middleware et le
  dossier `packages/fitness_domain/lib/middleware/` sont supprimés.
- `LayoutNotifierMiddleware` → le `builder:` de `MaterialApp.router`. Il était
  appliqué route par route ; `LayoutNotifier` enveloppe désormais l'application
  entière et n'est plus reconstruit à chaque navigation.
- 6 `Get.offNamed` → `context.go` (5 sites avec BuildContext) et
  `appRouter.go` (1 site : `LoginPageController`, qui n'a pas de contexte).

### Points d'attention

**Les traductions étaient portées par `GetMaterialApp`.** `.tr` lit
`Get.translations` / `Get.locale`, alimentés jusqu'ici par ce widget. Ils sont
maintenant configurés explicitement dans `main()` via `Get.addTranslations()`,
`Get.locale` et `Get.fallbackLocale` — API publiques et indépendantes du widget.
Les 91 `.tr` continuent donc de fonctionner jusqu'au chantier 4, qui supprimera
ces trois lignes. `Get.deviceLocale` est remplacé par
`PlatformDispatcher.instance.locale`.

**`appRouter` est exposé au niveau module** pour permettre la navigation depuis
un controller sans BuildContext. C'est un compromis temporaire : au chantier 3,
`LoginPageController` devenant un notifier possédé par sa page, la navigation
pourra remonter dans la page via un callback et cette dépendance disparaîtra.

**Les `Navigator.of(context).push(MaterialPageRoute(...))`** (calendrier →
séance, choix d'exercice, détail programme, stats) sont laissés tels quels : ils
cohabitent sans problème avec go_router. Les convertir en routes nommées est un
chantier de confort, pas un prérequis.

---

## Chantier 3 — Réactivité → notifiers ✅

Aucun `Obx`, `.obs`, `Rx*`, `GetxController` ni `GetxService` ne subsiste.

### Conversions appliquées

| GetX | Cible |
|---|---|
| `RxBool` / `RxString` / `RxInt` / `Rx<T>` | `ValueNotifier<T>` — la syntaxe `.value` est identique |
| `RxList<T>` | `ValueNotifier<List<T>>`, réassignée (voir piège ci-dessous) |
| `Obx(() => …)` sur une source | `ValueListenableBuilder<T>` |
| `Obx(() => …)` sur plusieurs | `ListenableBuilder` + `Listenable.merge` |
| `GetxController` + `onInit`/`onClose` | `ChangeNotifier` + constructeur / `dispose()` |
| `GetxService` | classe simple, `dispose:` déclaré à l'enregistrement get_it |

### Écrans repris, dans l'ordre

login → sign-up → profil → calendrier → recherche → séance. Chaque page est
devenue un `StatefulWidget` qui crée son notifier en champ, le libère en
`dispose()`, et le passe explicitement à ses sous-widgets par constructeur.

### Pièges rencontrés

**`ValueNotifier` ne notifie que sur changement de référence.** Là où le code
mutait l'objet sur place (`user.update((u) => u.name = …)` chez GetX), il faut
soit réassigner une nouvelle valeur, soit appeler `notifyListeners()`
explicitement. Les listes suivent la même règle : `stepperList.value = steps`
et non `stepperList.add(...)`.

**`GetMaterialApp` n'était pas seul en cause.** `SearchMixin` était contraint
`on GetxController` (chantier 1) ; il est passé `on ChangeNotifier` et son
`onClose()` est devenu `dispose()`.

### Dettes soldées

- `appRouter` n'est plus appelé depuis un notifier. `LoginPageController.authenticate()`
  et `SignUpController.validateSignUp()` renvoient un résultat ; c'est la page
  qui navigue, avec un contrôle de `mounted`.
- Le hack `onRefresh` de `WorkoutPageController` (« ATTENTION Il faut laisser
  cette ligne ») a disparu : `refreshWorkoutPage()` appelle simplement
  `notifyListeners()`, et la page écoute via `ListenableBuilder`.
- `ExerciseChoiceDialog` ne cherche plus le controller de séance dans le
  conteneur : la page lui passe un callback `onValidated`.
- `HidePasswordController` supprimé : ses deux booléens appartenaient au
  formulaire d'inscription, ils sont dans `SignUpController`.
- `MyProgramsPageController` supprimé : il ne portait aucun état, la page
  appelle le service directement.
- `GridView.count` → `GridView.builder` sur l'écran recherche (constat C4 de
  l'audit), au passage de la conversion.

### Constats au passage

- **`MyProgramsPage` n'est référencée nulle part** — page morte, non supprimée
  car hors périmètre de ce chantier.
- **`ConnectivityService` n'est jamais résolu** : enregistré dans `di`, mais
  aucun `di<ConnectivityService>()` dans le code, et son `isConnected` n'est lu
  nulle part. Le service ne s'exécute donc jamais.

## Chantier 4 — i18n → `gen-l10n` ✅

Choix du `gen-l10n` du SDK plutôt que `slang` : pas de dépendance tierce, et la
génération est déclenchée par `flutter pub get` / le build via `generate: true`,
sans passer par `build_runner`.

### Fait

- `l10n.yaml` à la racine, `nullable-getter: false` pour éviter le `!` partout.
- `lib/l10n/app_fr.arb` et `lib/l10n/app_en.arb` — 61 clés, générées depuis
  l'ancienne classe `FitnessTranslations`, qui est supprimée.
- `lib/l10n/l10n.dart` : extension `context.l10n`, plus court que
  `AppLocalizations.of(context)`. C'est le seul import à ajouter dans les pages.
- **90 sites** `'clé'.tr` → `context.l10n.clé`.
- `flutter_localizations` ajouté ; `localizationsDelegates` et
  `supportedLocales` branchés sur `MaterialApp.router`.
- Les 3 lignes `Get.addTranslations` / `Get.locale` / `Get.fallbackLocale`
  ajoutées au chantier 2 sont supprimées.
- `lib/l10n/gen/` est gitignoré : c'est du code généré, reconstruit à chaque
  `pub get`.

### Pièges rencontrés

**La clé `continue` est un mot réservé Dart.** gen-l10n en aurait fait un
`String get continue`, syntaxiquement invalide. Renommée `continueLabel` dans
les deux ARB et sur ses 2 points d'appel.

**`flutter_localizations` épingle `intl`.** La contrainte `intl: ^0.20.3` du
projet empêchait la résolution ; ramenée à `^0.20.2`.

**Deux concaténations manuelles** (`'$numberWeekInt ' + 'weeks'.tr` et
`'comment'.tr + '...'`) ont dû être converties en interpolation plutôt qu'en
simple substitution.

### Constat

4 clés sont traduites mais jamais utilisées : `addWorkout`, `home`, `plus`,
`tracking`. Conservées dans les ARB.

---

## Chantier 6 — `get_storage` → `shared_preferences` ✅

Dernière dépendance de l'écosystème GetX. `get_storage` n'avait pas été publié
depuis février 2023 ; `shared_preferences` est maintenu par l'équipe Flutter.

### Fait

- `shared_preferences: ^2.5.5` remplace `get_storage: ^2.1.1`.
- `configureDependencies()` devient `async` et charge `SharedPreferences` une
  fois, en `registerSingleton`. Toutes les lectures de préférences sont ensuite
  **synchrones**.
- `main()` devient `async`, avec `WidgetsFlutterBinding.ensureInitialized()`.
- `DarkModeController` prend `SharedPreferences` par constructeur. Le mécanisme
  `box.listenKey` de get_storage, qui servait à répercuter l'écriture sur le
  notifier, n'a plus lieu d'être : `switchDarkMode()` met à jour le notifier
  puis persiste.
- **`lib/widget/dark-mode.widget.dart` supprimé.** Il ne contenait que deux
  widgets dont l'unique rôle était d'attendre `GetStorage.init()` dans un
  `FutureBuilder` avant de construire l'application. L'initialisation étant
  remontée dans `main()`, ils n'ont plus d'objet — `GetStorageWidget` n'était
  d'ailleurs référencé nulle part.

### Effet de bord

Un `FutureBuilder` de moins à la racine de l'arbre : le thème est connu dès le
premier rendu, sans passage transitoire par un `Container()` vide.

---

## Chantier 7 — Fiabilité du démarrage ✅

Le point le plus probablement responsable du « rien ne s'affiche » : l'échec de
`Firebase.initializeApp()` n'était pas traité.

### Ce qui n'allait pas

```dart
FutureBuilder(
  future: Firebase.initializeApp(),   // relancé à chaque rebuild
  builder: (context, snapshot) {
    if (snapshot.hasData) { ... }
    return Container();               // échec = écran blanc muet
  },
)
```

Trois défauts cumulés : aucun `snapshot.hasError`, une future recréée à chaque
reconstruction, et `_configureFunctionsEmulator()` rejoué à chaque rebuild.

### Fait

- `MyApp` devient un `StatefulWidget` et lance l'initialisation **une seule
  fois**, dans `initState()`.
- Trois états explicites (`pending` / `ready` / `failed`) au lieu d'un
  `Container()` vide comme cas par défaut.
- L'échec est journalisé via `dart:developer` (niveau 1000) avec sa stack.
- `lib/page/startup_error.page.dart` : écran d'erreur avec bouton **Réessayer**
  (relance l'initialisation, sans redémarrer l'application) et un panneau
  « Détail technique » repliable exposant l'exception réelle.
- 3 clés ajoutées aux deux ARB : `startupFailed`, `startupFailedDescription`,
  `retry`.
- Le routeur n'est monté qu'une fois Firebase prêt : ses gardes interrogent
  `FirebaseAuth`, qui n'existe pas avant.

### Vérifié

Lancé sur simulateur iOS (iPhone 17 Pro). Firebase échoue bien — le plist était
alors absent — et l'écran d'erreur s'affiche à la place du blanc. Le plist a
depuis été ajouté (chantier 11), mais l'écran reste le filet de sécurité pour
toute autre panne d'initialisation.

### Trouvé en le vérifiant : le thème amber ne s'applique plus

La capture a révélé un accent **violet** au lieu de l'ambre de l'application.
Cause, confirmée dans le source de Flutter
(`material/theme_data.dart:444`) : en Material 3 — le mode par défaut depuis
Flutter 3.16 — si ni `colorScheme` ni `colorSchemeSeed` n'est fourni, ThemeData
retient la palette M3 de base (violet #6750A4). **`primarySwatch` n'est lu que
dans la branche Material 2.**

`Theming.getLightTheme()` et `getDarkTheme()` ne déclarent que
`primarySwatch: Colors.amber` : il est donc silencieusement ignoré, et
`Theme.of(context).primaryColor` renvoie du violet dans toute l'application.

Défaut **pré-existant**, apparu avec la montée de version du SDK, pas
introduit par ce chantier. → Traité au chantier 9.

---

## Chantier 8 — Réintégration des packages internes ✅

`packages/firebase` et `packages/fitness_domain` existaient parce que le domaine
était partagé avec l'application entraîneur. Ce n'est plus le cas : plus rien
n'est partagé, les deux packages ne servaient qu'à ajouter une frontière.

### Le package `firebase` n'a pas été déplacé, il a été supprimé

Une seule ligne du dépôt l'importait : `param.service.dart`.

`ParamService` héritait d'`AbstractAbsoluteFirestoreService`, donc d'une
quinzaine de méthodes CRUD et de pagination — **aucune n'était appelée**. Seul le
champ `collectionReference` servait. `mapSnapshotToModel`, imposé par la classe
abstraite, n'avait lui non plus aucun appelant. Et `firestorage.service.dart`
était intégralement mort.

Un simple champ `CollectionReference` a remplacé tout cet héritage : **3
fichiers, 158 lignes et un `pubspec.yaml` supprimés**, sans rien réintégrer.

### `fitness_domain` déplacé dans `lib/`

| Source | Destination |
|---|---|
| `lib/domain/` (21 fichiers) | `lib/domain/` |
| `lib/service/` (11 fichiers) | `lib/service/` |
| `lib/widget/` (4 fichiers) | `lib/widget/` |
| `lib/mixin/` | `lib/mixin/` |
| `constants.dart`, `di.dart` | fusionnés avec ceux de l'application |

Aucune collision de nom avec les fichiers déjà présents. Déplacements faits en
`git mv` pour conserver l'historique.

### Constantes dédupliquées

`FitnessNcColors` existait **deux fois à l'identique**, et la copie du package
n'était utilisée par aucun fichier du package. `FitnessMobileConstants` et
`FitnessConstants` se recouvraient sur `appTitle`, `textFormFieldHeight` et
`firebaseRegion`.

Le tout est fondu dans un seul `FitnessConstants` (le « Mobile » distinguait
cette application de l'application entraîneur : sans objet désormais). Deux
constantes sont tombées faute d'appelant : `bottomAppBar` et
`routePoliciesMobile`.

Au passage, une inversion de couches disparaît : les routes `routeLogin`,
`routeSignUp` et `routeHome` — des routes **de l'application** — étaient
déclarées dans le package domaine.

### Fait

- 133 imports réécrits en `package:fitnc_user/…` sur 45 fichiers.
- Doublons d'imports supprimés : 10 fichiers importaient `constants.dart` deux
  fois, via l'application **et** via le package, qui pointent maintenant vers le
  même fichier.
- `di.dart` : le locator `di`, jusque-là ré-exporté depuis le package, est
  déclaré directement.
- 4 dépendances remontées dans le `pubspec.yaml` racine : `file_picker`, `http`,
  `json_annotation`, `path`. `tuple` était déclaré par `fitness_domain` sans y
  être utilisé — disparu avec lui.
- `build_runner.sh` supprimé (la commande est dans le README).

### Piège rencontré

`stat-exercice.page.dart` importait la bibliothèque de graphiques **deux fois**,
une fois préfixée `as charts` et une fois sans. La déduplication d'imports a
donc cassé la référence non préfixée `SelectionModel`, devenue
`charts.SelectionModel`. Erreur relevée par `flutter analyze`, pas visible à la
lecture du diff.

### Vérifié

- `flutter analyze` : **0 erreur, 234 issues** — exactement le total d'avant
  fusion. Les fichiers des packages étaient déjà soumis à l'`analysis_options.yaml`
  racine, le déplacement ne change donc pas le décompte.
- `dart run build_runner build` : les 9 `*.g.dart` se régénèrent au nouvel
  emplacement (les directives `part` sont relatives, elles restent valides).
- `flutter build ios --simulator` : succès.
- Lancement sur simulateur : l'application démarre et se comporte comme avant.

### Bilan

Le dépôt ne contient plus qu'**un seul package Dart**. `lib/` : 79 fichiers,
9 810 lignes. `packages/` : supprimé. L'original reste disponible dans
`../fitnc-trainer/packages/` si besoin.

### Reste dans ce périmètre

- `ParamService` garde un singleton fait main (`getInstance()`) alors que le
  projet a `get_it` — non traité pour garder le chantier limité au déplacement.
- `listenListParam` n'a aucun appelant.

---

## Chantier 9 — Thème Material 3 ✅

### Le défaut d'origine

`primarySwatch: Colors.amber` n'est lu que dans la branche Material 2 de
`ThemeData`. En Material 3, sans `colorScheme` ni `colorSchemeSeed`, la palette
violette de base s'applique. L'application affichait donc du violet, sans le
moindre signal à la compilation ni à l'analyse.

Les deux thèmes reçoivent maintenant un `ColorScheme.fromSeed(seedColor:
FitnessNcColors.amber)`, dans leur luminosité respective.

### Pourquoi un `filledButtonTheme` en plus du seed

`fromSeed` assombrit volontairement l'ambre en thème clair : `primary` devient
un or foncé. Ce n'est pas un défaut, c'est la contrainte de contraste — de
l'ambre pur (#FFC107) sur fond blanc plafonne à ~1,7:1, très en deçà du seuil
AA. Utiliser l'ambre de la marque comme `primary` rendrait tous les libellés de
`TextButton` illisibles.

L'ambre est donc rétabli là où il est lisible : en aplat, avec du texte noir
(~11:1), via `filledButtonTheme`. Les rôles textuels gardent l'or foncé calculé
par M3.

### Le vrai piège : `primaryColor` en thème sombre

Vérification faite dans le source de Flutter (`theme_data.dart:447`) :

```dart
final Color primarySurfaceColor = isDark ? colorScheme.surface : colorScheme.primary;
primaryColor ??= primarySurfaceColor;
```

En thème **sombre**, `ThemeData.primaryColor` vaut donc `colorScheme.surface` —
la couleur du fond. Les **57** `Theme.of(context).primaryColor` de
l'application peignaient leurs icônes et leurs accents exactement de la couleur
de l'arrière-plan : **invisibles**. Constaté à l'écran, l'icône de la page de
démarrage ayant purement disparu en mode sombre.

Défaut pré-existant lui aussi, et probablement une part du « l'application
n'était pas fonctionnelle » : le mode sombre était inutilisable.

Les 57 occurrences passent à `Theme.of(context).colorScheme.primary`. Aucun
effet en thème clair, où les deux valeurs coïncident.

### Fait

- `colorScheme` explicite dans `getLightTheme()` et `getDarkTheme()`.
- `filledButtonTheme` partagé par les deux thèmes.
- 57 `primaryColor` → `colorScheme.primary` sur 17 fichiers.
- Dépréciations soldées dans `theming.dart` : `MaterialStateProperty` →
  `WidgetStateProperty` (4), `AppBarTheme.color` → `backgroundColor` (1).
  L'analyse passe de 234 à 230 issues.

### Vérifié

Les deux thèmes ont été observés sur simulateur, pas seulement compilés. Le mode
sombre a été forcé en écrivant `flutter.isDarkMode` dans le plist du conteneur
de l'application — `simctl spawn defaults write` n'atteint pas le bon domaine.

| | Avant | Après |
|---|---|---|
| Clair | bouton violet | bouton ambre, texte noir |
| Sombre | icône invisible | icône ambre clair sur fond chaud |

### Point d'attention

Quelques écrans posent du blanc sur un fond `primary` (`stat-exercice.page.dart`
notamment). En thème sombre, `primary` est un ambre clair : le blanc y contraste
mal. À revoir écran par écran quand l'application sera navigable.

---

## Chantier 10 — Deux bugs fonctionnels ✅

### `ConnectivityService` : un service que personne ne construisait

Il était déclaré en `registerLazySingleton`, donc construit à la **première
résolution**. Or aucun `di<ConnectivityService>()` n'existait dans le code : le
constructeur n'était jamais exécuté, l'écoute jamais ouverte, `isConnected`
jamais alimenté ni lu. La détection de connexion ne fonctionnait pas du tout.

- Passé en `registerSingleton` : l'écoute démarre au lancement, sans dépendre
  d'un écran qui penserait à le demander. C'est aussi ce qui empêche le bug de
  réapparaître.
- Nouveau `ConnectivityBanner`, dans le `builder` des deux `MaterialApp` donc
  au-dessus du `Navigator` : le bandeau reste visible quel que soit l'écran, y
  compris sur la page d'échec de démarrage — celle qui invite justement à
  vérifier sa connexion.
- Valeur initiale passée à `true`. À `false`, chaque lancement affichait un
  bandeau « hors ligne » le temps que la première vérification réponde.
- Garde `_disposed` : la vérification initiale est asynchrone et peut aboutir
  après la libération du service ; écrire dans un `ValueNotifier` libéré lève.
- `wifi || mobile` remplacé par `!= none` : un appareil en ethernet ou en VPN
  était compté comme hors ligne.

### `FitnessUserService.register()` : un succès affiché sur un échec

```dart
callable.call({...}).then((value) {
  print('Hello');
}).catchError((onError) {
  print(onError.toString());
});
```

L'appel à la Cloud Function n'était pas attendu : `register()` rendait la main
immédiatement, avant que le serveur ait répondu. Son résultat partait dans un
`print`, ses erreurs aussi. Et côté interface, `onPressed: () =>
notifier.register(...)` **jetait la `Future`** sans jamais la lire.

Conséquence : le bouton « Suivre » paraissait fonctionner dans tous les cas. Un
échec d'inscription était invisible pour l'utilisateur, qui ne voyait
simplement rien apparaître dans ses programmes.

- L'appel est `await`é ; les erreurs remontent à l'appelant.
- Le `Future.error("'Vous êtes déjà abonné…'")` — un message d'interface, en
  dur, avec des guillemets en trop — devient une `AlreadyRegisteredException`.
  C'est la couche présentation qui choisit le texte, et elle peut le traduire.
- Le site d'appel attend le résultat et affiche un toast, succès comme échec,
  en distinguant les deux causes. Les libellés sont résolus **avant** l'appel :
  le `context` d'un `StatelessWidget` ne doit pas être consulté après un
  `await`.
- 4 clés ajoutées aux deux ARB.

### Vérifié

- `flutter analyze` : 0 erreur, 230 issues (inchangé).
- Build iOS et lancement sur simulateur.
- Bandeau hors ligne observé à l'écran, en inversant temporairement sa
  condition d'affichage — le simulateur étant connecté, forcer `isConnected` à
  `false` ne suffisait pas : le service corrigeait la valeur dès sa première
  vérification. Ce qui confirmait au passage qu'il tourne enfin.

### Non vérifié à l'exécution

Le correctif de `register()` n'a pas pu être exercé : il demande un utilisateur
authentifié et une Cloud Function joignable, donc un Firebase fonctionnel, que
le simulateur n'a pas. Revue de code et compilation uniquement.

---

## Chantier 11 — Firebase iOS configuré ✅

Le projet Firebase `fitnc-7be2e` ne déclarait aucune application iOS : le
`GoogleService-Info.plist` n'existait donc nulle part, et `initializeApp()`
échouait à chaque lancement. Application iOS créée pour le bundle
`nc.deveo.fitness`, plist récupéré et versionné.

### Le fichier posé ne suffit pas

`project.pbxproj` ne mentionnait pas le plist. Sans appartenance à la phase
*Copy Bundle Resources*, il ne serait pas entré dans le bundle et l'échec aurait
été identique — avec un fichier pourtant visible dans `ios/Runner/`, ce qui est
la meilleure façon de chercher longtemps.

Déclaration faite avec le gem `xcodeproj` plutôt qu'à la main : les UUID et les
références croisées sont générés correctement. Diff vérifié contre une
sauvegarde prise juste avant — **4 lignes ajoutées, rien d'autre modifié**.

### Vérifié

- `GoogleService-Info.plist` présent dans `build/ios/iphonesimulator/Runner.app/`.
- `[I-COR000012] Could not locate configuration file` a disparu des logs.
- L'application dépasse l'écran d'erreur, monte le routeur, applique la garde
  d'authentification et affiche l'écran de connexion.

C'est le premier écran réel observé depuis le début de ces travaux : toutes les
vérifications précédentes s'arrêtaient à la page d'échec de démarrage.

### Constats sur le premier écran

- L'identité ambre est bien là (titre « Fitness Nc » en Anton ambre).
- Faute de frappe dans le pied de page : « Copyrigth @Deveo.nc ».
- Les libellés posés sur la photo (« Inscription », « Mot de passe oublié ? »)
  manquent de contraste — c'est exactement la réserve émise au chantier 9, à
  reprendre écran par écran maintenant que c'est observable.

---

## Chantier 12 — Suppression de `MyProgramsPage` ✅

Page morte depuis le début des chantiers : jamais référencée, absente du
routeur comme de la barre de navigation (`IndexPage` ne compte que trois
entrées). 52 lignes supprimées, aucune référence résiduelle, `flutter analyze`
inchangé à 0 erreur / 230 issues.

### Ce que la suppression acte

C'était le seul écran listant les programmes suivis. Le choix a été posé
explicitement : ni le profil, ni le calendrier, ni la recherche ne les
affichent, et la page n'était qu'une ébauche — chaînes en dur hors l10n
(« Mes programmes », « Error »), cartes réduites à un `Text(name)`.

Conséquence assumée : les programmes suivis ne sont visibles nulle part, et le
désabonnement perd son dernier point d'entrée possible. Voir « Reste à faire ».

---

## Chantier 13 — Retrait des abonnements et des coachs ✅

Décision produit : l'application ne sert plus qu'à **saisir ses entraînements,
les historiser et en suivre l'évolution**. Plus de souscription à un programme,
plus de suivi de coach.

### Vérifié avant de couper

`WorkoutInstance` ne référence aucun programme, et ni le calendrier, ni les
séances, ni les statistiques n'importaient quoi que ce soit du domaine
programme. Le cœur conservé était donc indépendant — c'est ce qui a rendu la
suppression sûre.

### Supprimé

| Fichier | Lignes |
|---|---|
| `page/search/search.page.dart` | 459 |
| `page/program-detail/program-detail.page.dart` | 276 |
| `page/search/search.notifier.dart` | 101 |
| `domain/published-programme.domain` (+ `.g`) | 71 |
| `domain/trainers.domain` (+ `.g`) | 67 |
| `domain/programme.domain` (+ `.g`) | 65 |
| `domain/workout.domain` (+ `.g`) | 56 |
| `service/published-programme.service.dart` | 46 |
| `service/trainers.service.dart` | 30 |

`workout.domain` n'était déjà plus référencé par personne : c'était le modèle
des séances *composant un programme*, distinct de `WorkoutInstance` qui porte
les séances réellement effectuées. Il part avec le reste de la fonctionnalité.

### Modifié

- `FitnessUserService` allégé de `register()`, `unregister()`,
  `addToFavorite()`, `listenMyPrograms()`, `getMyPrograms()`,
  `getMyProgramsReference()`, `_checkFitnessUserConnected()`,
  `AlreadyRegisteredException` et des deux constantes de collection associées.
  Le correctif d'`await` du chantier 10 disparaît donc avec la méthode qu'il
  corrigeait.
- `di.dart` : `TrainersService` et `PublishedProgrammeService` désenregistrés.
- `IndexPage` passe de trois à deux entrées ; la barre du bas perd l'onglet
  recherche et ne garde que **calendrier** et **profil**.
- 6 clés retirées des deux ARB (`follow`, `trainer`, `search`,
  `programFollowed`, `alreadyFollowingProgram`, `errorWhileFollowingProgram`).
  `searching` est conservée : elle sert au choix d'exercices.
- `badges` retiré du `pubspec.yaml`, devenu sans usage.

`search.mixin.dart` est conservé : le choix d'exercices s'en sert toujours.

### Vérifié

- `flutter analyze` : 0 erreur. **213 issues, contre 230** avant le chantier.
- Build iOS et lancement sur simulateur : l'application démarre normalement.
- `lib/` : 76 fichiers, **8 690 lignes** (contre 9 994 avant).

### Non vérifié

La barre à deux onglets n'a pas été observée : elle est derrière l'écran de
connexion, et aucun compte de test n'est disponible.

---

## Chantier 14 — `storage-image.widget.dart` ✅

L'audit initial signalait « 351 lignes, 3 classes quasi identiques » et
proposait de les mutualiser. Vérification faite, il n'y avait rien à
mutualiser : **une seule des quatre classes était utilisée**.

| Classe | Lignes | Appelants |
|---|---|---|
| `StorageImageWidget` | 103 | 2 (profil, ajout d'exercice) |
| `StorageStreamImageWidget` | 116 | 0 |
| `StorageFutureImageWidget` | 107 | 0 |
| `StorageImageFormField` | 9 | 0 (servait aux deux précédentes) |

Les deux variantes mortes ne différaient de la vivante que par la source de
l'image — un `Future` pour l'une, un `Stream` pour l'autre. `232 lignes`
supprimées sans rien fusionner.

### La classe restante, réécrite

- Les trois branches `if/else if/else` construisaient trois `CircleAvatar`
  identiques à l'image près. Elles se réduisent à un getter `_image` et un seul
  `CircleAvatar` : `backgroundImage` accepte `null`.
- `onTap()` passait par `.then()` ; désormais `async`/`await`.
- `borderRadius` était figé à `Radius.circular(50)` alors que `radius` est
  paramétrable — le profil l'appelle avec `radius: 80`, la zone cliquable ne
  correspondait donc pas à l'avatar.
- `EdgeInsets.all(0)` → `EdgeInsets.zero`, `Key? key` → `super.key`.
- Le tooltip « Supprimer la photo », en dur, passe par l10n (clé `deletePhoto`).

### Changement de comportement assumé

Le bouton de suppression était affiché **en permanence** : sans photo à
supprimer, et même sans rappel `onDeleted` branché, auquel cas l'appui ne
faisait rien. Il n'apparaît plus que s'il y a une image **et** un rappel. Les
deux appelants fournissent toujours `onDeleted` : pour eux, seul le cas « pas
de photo » change.

### Vérifié

- `flutter analyze` : 0 erreur, **201 issues** contre 213.
- Build iOS, lancement sur simulateur, aucune exception au démarrage.
- `lib/` : **8 457 lignes**.

### Non vérifié

Le widget vit sur le profil et l'ajout d'exercice, tous deux derrière
l'authentification. Le rendu et la sélection de fichier n'ont pas été exercés.

---

## Chantier 15 — Dépendances inutilisées ✅

Section B de l'audit initial, enfin soldée. Cinq paquets déclarés dans le
`pubspec.yaml` sans qu'aucun fichier de `lib/`, `test/` ou `web/` ne les
importe :

| Paquet | Remarque |
|---|---|
| `date_picker_timeline` | remplacé de longue date par `fitness-date-picker.widget.dart` |
| `fab_circular_menu` | aucun menu circulaire dans l'application |
| `cron` | aucune tâche planifiée côté client |
| `camera` | aucune prise de vue ; les images passent par `file_picker` |
| `cupertino_icons` | valeur par défaut du template Flutter, aucune icône Cupertino utilisée |

`flutter pub get` résout **9 dépendances de moins** (les cinq paquets et leurs
transitives).

### Vérifié

- `flutter analyze` : 0 erreur, 201 issues — inchangé, ces paquets n'étaient
  référencés nulle part.
- `camera` a disparu de la liste des plugins iOS
  (`.flutter-plugins-dependencies`).
- Build iOS et lancement sur simulateur : aucune exception.

### Conséquence à trancher — `Info.plist`

`ios/Runner/Info.plist` déclare encore deux autorisations que plus aucun plugin
ne peut utiliser, `camera` étant parti :

- `NSCameraUsageDescription` — « prendre une photo de profil et illustrer vos
  exercices »
- `NSMicrophoneUsageDescription` — « enregistrer le son de vos vidéos
  d'exercices »

Non retirées : ces libellés ont été écrits à la main, en français, et décrivent
une fonctionnalité manifestement prévue. Apple interroge les autorisations
déclarées mais jamais exercées lors de la revue App Store — à supprimer si la
prise de vue est abandonnée, à garder si elle revient.

`NSPhotoLibraryUsageDescription` est conservée dans tous les cas : `file_picker`
en a besoin pour la sélection d'images.

---

## Reste à faire

### Tests — volontairement repoussés

`test/` est vide. C'est un choix assumé : l'application n'était pas
fonctionnelle et de gros refactos restent à venir. Écrire des tests sur du code
voué à être réécrit serait du travail perdu. **À ouvrir une fois les refontes
terminées**, pas avant.

### Dette signalée pendant les chantiers, non traitée

- Sections C et D de l'audit initial : futures recréées dans `build`, et le
  dernier gros doublon — les deux écrans de login jumeaux.
- `ios/Runner/Info.plist` déclare la caméra et le micro sans qu'aucun plugin ne
  les utilise (voir chantier 15).
- Faute de frappe « Copyrigth @Deveo.nc » sur l'écran de connexion.
- Contrastes faibles sur les libellés posés sur photo, et blanc sur `primary`
  en thème sombre (voir chantiers 9 et 11).
