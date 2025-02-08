import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnc_user/page/home/my-infos.dart';
import 'package:fitness_domain/widget/layout-display.widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import 'home.notifier.dart';

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
