# fitness

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
"# fitness" 

## Organisation de `lib/`

Le projet ne contient **qu'un seul package Dart**. Les packages internes
`firebase` et `fitness_domain`, hérités du dépôt voisin `olivejp/fitnc-trainer`,
ont été réintégrés dans `lib/` : plus de `path:` dans le `pubspec.yaml`, plus de
`packages/`.

| Dossier | Contenu |
|---|---|
| `lib/domain/` | Modèles métier et leur sérialisation (`*.g.dart` générés) |
| `lib/service/` | Services Firestore, authentification, utilitaires |
| `lib/page/` | Écrans, un répertoire chacun, avec son notifier (modèle page / notifier) |
| `lib/widget/` | Widgets partagés par au moins deux écrans |
| `lib/mixin/` | Mixins partagées (recherche, stockage Firebase) |
| `lib/l10n/` | Fichiers ARB ; `lib/l10n/gen/` est généré et non versionné |

Le code généré par `json_serializable` se régénère avec :

```sh
dart run build_runner build
```

Si `fitnc-trainer` doit rester aligné sur ces modèles, la synchronisation est
manuelle — les deux dépôts sont désormais indépendants.

## To build and install on a phone
- Connect a phone
- Launch the buildApkAndInstall.sh

## iOS

Le dossier `ios/` cible iOS 15 minimum (imposé par le SDK Firebase) et le bundle
identifier `nc.deveo.fitness`.

Les plugins sont intégrés via **Swift Package Manager**, pas CocoaPods : il n'y a
volontairement pas de `Podfile`. En ajouter un réintroduit CocoaPods dans le
projet et casse le build (`The sandbox is not in sync with the Podfile.lock`).

### Configuration Firebase

`ios/Runner/GoogleService-Info.plist` est versionné, et **déclaré dans la cible
Runner** du projet Xcode. Ce second point est indispensable : un plist présent
sur le disque mais absent de la phase *Copy Bundle Resources* n'entre pas dans
le bundle, et `Firebase.initializeApp()` échoue exactement comme si le fichier
n'existait pas (`[I-COR000012] Could not locate configuration file`).

Pour le régénérer (compte ayant accès au projet `fitnc-7be2e` requis) :

```sh
firebase apps:list --project fitnc-7be2e
firebase apps:sdkconfig ios <APP_ID> --project fitnc-7be2e \
  -o ios/Runner/GoogleService-Info.plist
```

Le fichier n'est pas un secret — il est embarqué dans l'application livrée, au
même titre que `android/app/google-services.json`.

```
flutter run -d <device-ios>
```

## Generate Launcher Icon
To change the launcher icon (icon located on the dock of an phone).
You have to specify the icon to be use in the pubspec.yaml

``
flutter_launcher_icons:
android: "launcher_icon"
ios: true
image_path: "images/fitness_logo.png"
remove_alpha_ios: true
``

generateLauncherIcon.sh

## Build AAB
To build the .aab, run the buildAppBundle.sh at the root of the project.
The output is located in ./build/app/outputs/bundle/release/app-release.aab

## Deploy 
Go to 
- [Play Store console](https://play.google.com/console/)