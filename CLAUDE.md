# CLAUDE.md

Instructions pour Claude Code travaillant dans ce dépôt.

## Le projet

`fitnc_user` — application Flutter (Android, iOS, web, desktop) côté **pratiquant**
de Fitness-Nc : catalogue d'exercices, programmes publiés par des coachs, séances
et statistiques de progression.

Backend **Firebase** : Auth, Firestore, Storage, Cloud Functions (région
`australia-southeast1`, cf. `FitnessConstants.firebaseRegion`).

Le dépôt ne contient **qu'un seul package Dart**. Les anciens packages internes
`firebase` et `fitness_domain` ont été réintégrés dans `lib/` ; il n'y a plus de
`packages/` ni de dépendance `path:` dans le `pubspec.yaml`.

L'écosystème **GetX est entièrement sorti** du projet (voir `MIGRATION.md`).
Ne jamais réintroduire `get`, `get_storage`, `Get.put`, `Get.find`, `Obx`, `.obs`.

## Commandes

```sh
flutter pub get                                          # + gen-l10n (generate: true)
flutter analyze                                          # doit rester à 0 error
flutter run -d <device>
dart run build_runner build --delete-conflicting-outputs # régénère les *.g.dart
dart fix --apply --code=<nom_du_lint>                    # correction ciblée, jamais `dart fix --apply` seul
./buildApkAndInstall.sh                                  # APK debug + install sur le téléphone branché
./buildAppBundle.sh                                      # .aab release → build/app/outputs/bundle/release/
./generateLauncherIcon.sh
```

`flutter analyze` remonte des `info` et des `warning` préexistants : ne pas les
corriger en masse. En revanche **aucune `error` ne doit subsister** avant de
rendre la main.

## Règle Git — obligatoire

**Tout fichier créé ou modifié est ajouté à l'index immédiatement**, dans la
foulée de l'édition :

```sh
git add <chemin>
```

- Renommer/déplacer se fait avec `git mv`, jamais avec `mv`.
- Supprimer se fait avec `git rm`.
- Un fichier généré (`*.g.dart`) est indexé au même titre que sa source.
- `git commit` et `git push` ne sont faits **que sur demande explicite** de
  l'utilisateur. Indexer n'est pas commiter.

## Convention de nommage — fixe

Format : **`<nom>.<type>.dart`**

1. Le **nom** est en minuscules, les mots séparés par des **tirets `-`**.
   Jamais d'underscore `_`, jamais de point dans le nom lui-même.
2. Un **seul point** sépare le nom du type.
3. Le **type** vient de la liste fermée ci-dessous.
4. Si la classe n'entre dans aucun de ces types **et** que son nom suffit à
   comprendre sa fonction, on n'ajoute rien : `constants.dart`, `router.dart`,
   `theming.dart`, `di.dart`, `firebase-query-condition.dart`, `i-from-json.dart`.
5. Les **dossiers** suivent la même règle du tiret : `my-programs/`,
   `program-detail/`.
6. Le mot **`controller` est banni** — des noms de fichiers, des noms de classes
   et des noms de variables. Les seuls `Controller` légitimes sont ceux de
   Flutter (`TextEditingController`, `ScrollController`, `PageController`…).

| Type | Quand | Suffixe de classe | Exemple |
|---|---|---|---|
| `.notifier.dart` | la classe étend `ChangeNotifier` | `…Notifier` | `search.notifier.dart` → `SearchNotifier` |
| `.page.dart` | un écran complet (route go_router ou `Navigator.push`) | `…Page` | `calendar.page.dart` → `CalendarPage` |
| `.form.dart` | un formulaire réutilisable | `…Form` | `sign-up.form.dart` → `SignUpForm` |
| `.widget.dart` | tout autre widget : carte, dialog, bouton, graphe | nom explicite | `bottom.widget.dart` → `BottomCu` |
| `.service.dart` | sans état d'écran, vit toute la session | `…Service` | `auth.service.dart` → `AuthService` |
| `.domain.dart` | modèle métier sérialisable | nom du modèle | `exercice.domain.dart` → `Exercice` |
| `.mixin.dart` | une mixin | `…Mixin` | `search.mixin.dart` → `SearchMixin` |

Un **dialog est un widget** : `exercice-choice.widget.dart`. Il n'existe pas de
suffixe `.dialog.dart`, `.card.dart` ni `.controller.dart`.

### Un fichier, un type dominant

Un notifier ne cohabite **jamais** avec sa page. Chaque écran qui porte de l'état
a sa paire :

```
lib/page/profile/profile.notifier.dart   → ProfileNotifier extends ChangeNotifier
lib/page/profile/profile.page.dart       → ProfilePage + ses sous-widgets
```

Les widgets purement locaux à un écran (cartes, barres, sous-vues) restent dans
le `.page.dart` de cet écran. Dès qu'un widget sert à **deux écrans**, il part
dans `lib/widget/` — un écran n'importe jamais un autre écran pour lui prendre
un widget.

### Un répertoire par écran

`lib/page/<écran>/` contient **un seul** écran, et son nom est celui de l'écran.
Pas de regroupement thématique : `add-exercice/`, `stat-exercice/` et
`exercice/` sont trois répertoires frères, pas trois fichiers d'un répertoire
`exercice/`. De même `login/` et `sign-up/`.

Une présentation alternative du même écran reste dans son répertoire, en
`<écran>-desktop.page.dart` / `<écran>-mobile.page.dart` — c'est le même écran,
pas un autre.

```
lib/page/sign-up/
├── sign-up.notifier.dart        l'état
├── sign-up.page.dart            l'écran, choisit la présentation
├── sign-up.form.dart            le formulaire + son typedef et ses constantes
├── sign-up-desktop.page.dart    présentation large
└── sign-up-mobile.page.dart     présentation compacte
```

### Imports

Toujours la forme `package:fitnc_user/...`, y compris entre fichiers d'un même
répertoire. Les imports relatifs cassent silencieusement au premier déplacement
de fichier. Seules exceptions : les directives `part` / `part of` des `.g.dart`,
qui doivent rester relatives.

### Fichiers générés

- `x.domain.g.dart` accompagne `x.domain.dart` et suit son nom. Après toute
  modification d'un domain : `dart run build_runner build --delete-conflicting-outputs`,
  puis `git add` du `.g.dart`.
- `lib/l10n/gen/` est produit par gen-l10n et **git-ignoré** : ne pas le
  renommer, ne pas l'éditer, ne pas l'indexer.

## Structure de `lib/`

```
lib/
├── main.dart                    Amorçage : configureDependencies() puis MyApp
├── di.dart                      Locator get_it `di` + configureDependencies()
├── router.dart                  go_router : appRouter + garde d'authentification
├── constants.dart               FitnessConstants, FitnessNcColors, enums globales
├── theming.dart                 Thèmes clair/sombre Material 3
│
├── domain/                      Modèles métier + sérialisation json_serializable
│   ├── abstract.domain.dart     AbstractDomain / AbstractStorageDomain /
│   │                            AbstractSubDomain / InterfaceDomainSearchable
│   └── *.domain.dart (+ .g.dart)
│
├── service/                     Sans état d'écran, portée session
│   ├── abstract-crud.service.dart   Interfaces CRUD (IReaderService, IWriteService…)
│   ├── abstract.service.dart        Implémentations Firestore génériques
│   ├── i-from-json.dart             Interface de désérialisation
│   ├── firebase-query-condition.dart
│   └── *.service.dart
│
├── page/                        Un répertoire par écran (voir « Un répertoire par écran »)
│   ├── add-exercice/     add-user-set/    calendar/      exercice/
│   ├── exercice-choice/  login/           main/          my-programs/
│   ├── profile/          program-detail/  search/        sign-up/
│   └── startup-error/    stat-exercice/   workout-instance/
│
├── widget/                      Widgets partagés par au moins deux écrans
├── mixin/                       search.mixin.dart, fitness-storage.mixin.dart
└── l10n/                        app_en.arb, app_fr.arb, l10n.dart ; gen/ est généré
```

## Architecture

### Modèle page / notifier

- Un **service** est sans état d'écran, vit toute la session, et est enregistré
  dans `get_it` (`lib/di.dart`).
- Un **notifier** porte l'état d'**un** écran. Il est possédé par sa page
  (`StatefulWidget`), créé en champ `final` ou en `initState()`, libéré en
  `dispose()`. **Il n'est jamais enregistré dans `get_it`.**
- Une **page** instancie son notifier et le passe explicitement à ses
  sous-widgets par le constructeur — paramètre nommé **`notifier`** — jamais par
  résolution globale depuis `build()`.

```dart
class _ProfilePageState extends State<ProfilePage> {
  final ProfileNotifier notifier = ProfileNotifier();

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProfileHeader(notifier: notifier);
}
```

Interdits, ce sont les bugs que ce modèle a servi à éliminer :

- instancier un notifier ou résoudre un service depuis `build()` ;
- enregistrer un notifier dans `get_it` ;
- déclarer un notifier en champ d'un `StatelessWidget`.

### Réactivité

`ValueNotifier` + `ValueListenableBuilder` pour un champ isolé, `ChangeNotifier` +
`notifyListeners()` pour l'écran. Tout `ValueNotifier`, `StreamSubscription`,
`StopWatchTimer` ou `AudioPlayer` détenu par un notifier doit être libéré dans son
`dispose()`.

### Injection — `get_it`

`configureDependencies()` est appelé dans `main()` **avant** `runApp`. Résolution
par `di<MonService>()`. Tous les services sont en `registerLazySingleton`, ce qui
laisse get_it démêler l'ordre des dépendances. Ceux qui portent une souscription
ou un notifier déclarent le paramètre `dispose:`.

`ParamService` fait exception : c'est un singleton maison
(`ParamService.getInstance()`), il n'est pas dans `get_it`.

### Routage — `go_router`

`appRouter` dans `lib/router.dart`, exposé au niveau module pour que le code sans
`BuildContext` puisse naviguer. Depuis un widget : `context.go(...)`. Les chemins
sont des constantes de `FitnessConstants` (`routeHome`, `routeLogin`,
`routeSignUp`). `_guardConnected` redirige vers `/login` toute route non publique
sans utilisateur connecté. La navigation interne à un écran passe par
`Navigator.push(MaterialPageRoute(...))`.

### i18n — `gen-l10n`

Fichiers ARB dans `lib/l10n/` (`app_en.arb`, `app_fr.arb`), configuration dans
`l10n.yaml`. Accès via l'extension de `lib/l10n/l10n.dart` :

```dart
Text(context.l10n.maCle)
```

Aucun libellé affiché ne doit être écrit en dur. Toute nouvelle clé est ajoutée
dans **les deux** fichiers ARB.

### Domaine et sérialisation

`AbstractDomain` (`uid`, `name`, `createDate`, `updateDate`, `creatorUid`)
→ `AbstractStorageDomain` (ajoute `imageUrl`, `imageName`, `storageFile`)
→ `AbstractSubDomain` (ajoute `getParentUid()` pour les sous-collections).
`InterfaceDomainSearchable.searchFields()` alimente `SearchMixin`.

### Services Firestore

Un service par collection, dérivant de `AbstractFitnessCrudService` ou de
`AbstractFitnessStorageService` (qui compose `FitnessStorageMixin` pour l'upload
d'images). `AbstractFirebaseSubcollectionCrudService` résout son service parent
par paramètre de type : le service parent **doit** être enregistré dans `get_it`,
sinon l'échec est à l'exécution et non à la compilation.

### Thème

Material 3, `ColorScheme.fromSeed(seedColor: FitnessNcColors.amber)`. Ne pas
réintroduire `primarySwatch` : il est ignoré depuis M3 et fait retomber
l'application sur la palette violette par défaut. Couleurs dans
`FitnessNcColors`, thèmes dans `Theming`.

## Pièges connus

- **iOS** : les plugins passent par Swift Package Manager, il n'y a
  volontairement **pas de `Podfile`**. En ajouter un casse le build. Le fichier
  `ios/Runner/GoogleService-Info.plist` doit être déposé manuellement avant le
  premier lancement.
- **Firebase** est initialisé une seule fois dans `_MyAppState.initState()`,
  jamais depuis `build()`. Le routeur n'est monté qu'une fois l'init réussie, ses
  gardes interrogeant `FirebaseAuth`.
- **`Stepper`** : le nom est pris par Material. Le stepper de séance s'appelle
  `WorkoutStepper` (`workout-instance.notifier.dart`).
- **`ValueNotifier`** ne notifie que sur changement de *référence*. Après une
  mutation en place de l'objet contenu, appeler `notifyListeners()` explicitement
  (voir `setStoragePair`).
- **`test/widget_test.dart`** est le test compteur généré par `flutter create` :
  il ne correspond pas à cette application et échoue.
- **`MIGRATION.md`** retrace la sortie de GetX et la réintégration des packages
  internes. Le mettre à jour si l'un de ces chantiers reprend.

## Style de code

- Commentaires et documentation **en français**, comme le reste du code.
- Types explicites sur les déclarations, à l'image du code existant.
- Expliquer *pourquoi* dans les commentaires — le *quoi* se lit dans le code.
