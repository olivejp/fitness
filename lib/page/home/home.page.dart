import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnc_user/domain/utilisateur.domain.dart';
import 'package:fitnc_user/repository/utilisateur.repository.dart';
import 'package:fitnc_user/service/supabase/supabase.auth.service.dart';
import 'package:fitness_domain/widget/layout-display.widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

class HomePageNotifier extends ChangeNotifier {
  Utilisateur? _utilisateur;

  Utilisateur? get utilisateur => _utilisateur;

  set utilisateur(Utilisateur? value) {
    _utilisateur = value;
    notifyListeners();
  }

  void init() {
    final UtilisateurRepository utilisateurRepository = GetIt.I.get();
    final SupabaseAuthService supabaseAuthService = GetIt.I.get();
    utilisateurRepository.getById(supabaseAuthService.getConnectedUser()?.id).then((value) {
      utilisateur = value;
    });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutNotifier(
      child: ChangeNotifierProvider.value(
        value: HomePageNotifier(),
        builder: (context, child) {
          final HomePageNotifier homePageNotifier = Provider.of<HomePageNotifier>(context, listen: false);
          homePageNotifier.init();
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                toolbarHeight: 45,
                foregroundColor: Colors.white,
                backgroundColor: Colors.white,
                centerTitle: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Consumer<HomePageNotifier>(
                      builder: (_, HomePageNotifier controller, __) => CircleAvatar(
                        radius: 20,
                        foregroundColor: Theme.of(context).primaryColor,
                        foregroundImage: (controller.utilisateur?.photoUrl != null)
                            ? CachedNetworkImageProvider(controller.utilisateur!.photoUrl!)
                            : null,
                      ),
                    ),
                  )
                ],
                title: Consumer<HomePageNotifier>(
                  builder: (_, HomePageNotifier controller, __) {
                    String name = '${controller.utilisateur?.nom} ${controller.utilisateur?.prenom}';
                    return Text(
                      '${'welcome'.i18n()} $name 👋',
                      style: GoogleFonts.antonio(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
              ),
              body: const SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyInfos(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyInfos extends StatelessWidget {
  const MyInfos({super.key});

  final double squareSize = 120;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'Mes informations',
              style: GoogleFonts.antonio(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(
            height: squareSize,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shrinkWrap: true,
              itemCount: 4,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                switch (index) {
                  default:
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: SizedBox(width: squareSize, child: const Card()),
                    );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
