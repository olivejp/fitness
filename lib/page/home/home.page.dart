import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home.controller.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final HomeController controller = Get.put(HomeController());

  final double radius = 15;
  final TextStyle welcomeTextStyle = GoogleFonts.nunito(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.w900,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 45,
          elevation: 1,
          foregroundColor: Colors.white,
          backgroundColor: Colors.white,
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: FutureBuilder<FitnessUser?>(
                future: controller.getConnectedUser(),
                builder: (context, snapshot) => CircleAvatar(
                  radius: radius,
                  foregroundColor: Theme.of(context).primaryColor,
                  foregroundImage:
                      (snapshot.hasData && snapshot.data?.imageUrl != null)
                          ? CachedNetworkImageProvider(snapshot.data!.imageUrl!)
                          : null,
                ),
              ),
            )
          ],
          title: FutureBuilder<FitnessUser?>(
            future: controller.getConnectedUser(),
            builder: (_, snapshot) {
              String? name = '';
              if (snapshot.hasData) {
                name = snapshot.data!.prenom;
              }
              return Text(
                'Bienvenue $name 👋',
                style: welcomeTextStyle,
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              MyInfos(),
            ],
          ),
        ),
      ),
    );
  }
}

class MyInfos extends StatelessWidget {
  const MyInfos({Key? key}) : super(key: key);
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
              style:
                  GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900),
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
