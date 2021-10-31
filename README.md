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

## To build and install on a phone
- Connect a phone
- Launch the buildApkAndInstall.sh

## Generate Launcher Icon
To change the launcher icon (icon located on the dock of an phone).
You have to specify the icon to be use in the pubspec.yaml

``
flutter_icons:
android: "launcher_icon"
ios: true
image_path: "images/fitness_logo.png"
``

generateLauncherIcon.sh

## Build AAB
To build the .aab, run the buildAppBundle.sh at the root of the project.

## Deploy 
Go to 
- [Play Store console](https://play.google.com/console/)