import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitnc_user/di.dart';
import 'package:fitnc_user/domain/fitness-user.domain.dart';
import 'package:fitnc_user/service/auth.service.dart';
import 'package:flutter/material.dart';

class SignUpNotifier extends ChangeNotifier {
  final FitnessUserService fitnessUserService = di<FitnessUserService>();
  final AuthService authService = di<AuthService>();

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String> errors = ValueNotifier<String>('');

  // Visibilité des deux champs mot de passe. Ces deux booléens vivaient dans un
  // HidePasswordController séparé, alors qu'ils appartiennent à ce formulaire.
  final ValueNotifier<bool> hidePassword1 = ValueNotifier<bool>(true);
  final ValueNotifier<bool> hidePassword2 = ValueNotifier<bool>(true);

  String name = '';
  String prenom = '';
  String email = '';
  String telephone = '';
  String password = '';
  String passwordCheck = '';

  @override
  void dispose() {
    isLoading.dispose();
    errors.dispose();
    hidePassword1.dispose();
    hidePassword2.dispose();
    super.dispose();
  }

  void switchPassword1() {
    hidePassword1.value = !hidePassword1.value;
  }

  void switchPassword2() {
    hidePassword2.value = !hidePassword2.value;
  }

  void setError(String error) {
    errors.value = error;
  }

  void cleanError() {
    errors.value = '';
  }

  Future<UserCredential> signUp() async {
    // Méthode pour s'enregistrer sur Firebase.
    final UserCredential credential = await authService.signUp(email, password);

    // Création et sauvegarde d'un Utilisateur
    final FitnessUser user = FitnessUser();
    user.uid = credential.user!.uid;
    user.email = email;
    user.prenom = prenom;
    user.telephone1 = telephone;
    user.name = name;
    await fitnessUserService
        .getCollectionReference()
        .doc(user.uid)
        .set(user.toJson());

    // On se log pour la première fois avec le compte et on renvoie le credential.
    await authService.signInWithEmailPassword(email, password);

    return credential;
  }

  ///
  /// Renvoie le credential en cas de succès, null sinon. La navigation
  /// appartient à la page.
  ///
  Future<UserCredential?> validateSignUp(GlobalKey<FormState> formKey) async {
    cleanError();
    if (formKey.currentState?.validate() != true) {
      return null;
    }

    isLoading.value = true;
    try {
      return await signUp();
    } on FirebaseAuthException catch (error) {
      setError(error.message ?? '');
      return null;
    } catch (error) {
      setError(error.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
