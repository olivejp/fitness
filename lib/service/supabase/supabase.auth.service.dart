import 'package:fitnc_user/service/debug_printer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  // Get a reference your Supabase client
  final supabase = Supabase.instance.client;

  User? getConnectedUser() {
    return supabase.auth.currentUser;
  }

  /// Méthode permettant la création d'un compte utilisateur.
  Future<User?> signUp(String email, String password) async {
    DebugPrinter.printLn('signUp');

    final AuthResponse res = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    return res.user;
  }

  /// Méthode permettant de se connecter à Supabase avec un email et un mot de passe.
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    DebugPrinter.printLn('loginWithEmailAndPassword');

    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return res.user;
  }

  /// Méthode permettant de se connecter à Supabase avec un email et un mot de passe.
  Future<void> signOut() async {
    DebugPrinter.printLn('signOut');

    await supabase.auth.signOut();
  }

  /// Méthode permettant le reset d'un password pour l'utilisateur
  Future<void> resetPasswordForEmail(String email) async {
    DebugPrinter.printLn('resetPasswordForEmail');

    return supabase.auth.resetPasswordForEmail(email);
  }

  /// Méthode permettant d'écouter s'il y a un changement d'utilisateur connecté.
  Stream<User?> listenUserConnected() {
    return supabase.auth.onAuthStateChange.map(
      (event) => event.session?.user,
    );
  }

  /// Permet de récupérer l'utilisateur connecté
  static User? getUserConnected() {
    return Supabase.instance.client.auth.currentUser;
  }

  /// Permet de récupérer l'utilisateur connecté
  bool isConnected() {
    return Supabase.instance.client.auth.currentUser != null;
  }
}
