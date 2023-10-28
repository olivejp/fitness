import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnc_user/service/fitness-user.service.dart';
import 'package:fitness_domain/domain/fitness-user.domain.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FitnessUserService fitnessUserService = GetIt.I.get();

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
                future: fitnessUserService.getConnectedUser(),
                builder: (context, snapshot) => CircleAvatar(
                  radius: 15,
                  foregroundColor: Theme.of(context).primaryColor,
                  foregroundImage: (snapshot.hasData && snapshot.data?.imageUrl != null)
                      ? CachedNetworkImageProvider(snapshot.data!.imageUrl!)
                      : null,
                ),
              ),
            )
          ],
          title: FutureBuilder<FitnessUser?>(
            future: fitnessUserService.getConnectedUser(),
            builder: (_, snapshot) {
              String? name = '';
              if (snapshot.hasData) {
                name = snapshot.data!.prenom;
              }
              return Text(
                'Bienvenue $name 👋',
                style: GoogleFonts.nunito(
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
              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900),
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
