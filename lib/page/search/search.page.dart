import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnc_user/page/search/program_detail/program_detail.page.dart';
import 'package:fitnc_user/page/search/search.controller.dart';
import 'package:fitnc_user/service/published_programme.service.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:fitness_domain/service/display.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';

class SearchPage extends StatelessWidget {
  SearchPage({Key? key}) : super(key: key);
  final SearchPageController controller = Get.put(SearchPageController());
  final DisplayTypeService displayTypeController = Get.find();

  @override
  Widget build(BuildContext context) {
    controller.initSearchList(
        getStreamList: controller.publishedProgrammeService.listenAll);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTrainers(height: 200, width: 100),
                    ListPublishedPrograms(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ListPublishedPrograms extends StatelessWidget {
  ListPublishedPrograms({
    Key? key,
  }) : super(key: key);

  final SearchPageController controller = Get.find();
  final DisplayTypeService displayTypeController = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: StreamBuilder<List<PublishedProgramme>>(
        stream: controller.streamList,
        initialData: const <PublishedProgramme>[],
        builder: (_, AsyncSnapshot<List<PublishedProgramme>> snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Programmes récents",
                        style: GoogleFonts.comfortaa(fontSize: 22),
                      ),
                      Text(
                        "${snapshot.data!.length} résultats",
                        style: GoogleFonts.comfortaa(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Obx(
                    () {
                      int crossAxisCount;
                      switch (displayTypeController.displayType.value) {
                        case DisplayType.desktop:
                          crossAxisCount = 4;
                          break;
                        case DisplayType.tablet:
                          crossAxisCount = 2;
                          break;
                        default:
                          crossAxisCount = 1;
                      }
                      return GridView.count(
                        controller: _scrollController,
                        semanticChildCount: snapshot.data!.length,
                        shrinkWrap: true,
                        mainAxisSpacing: 20,
                        childAspectRatio: 16 / 9,
                        crossAxisCount: crossAxisCount,
                        children: snapshot.data!
                            .map((PublishedProgramme programme) =>
                                PublishedProgrammeCard(
                                    publishedProgramme: programme))
                            .toList(),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text('Aucun programme publié'),
            );
          }
          return Center(
              child: LoadingBouncingGrid.circle(
            backgroundColor: Theme.of(context).primaryColor,
          ));
        },
      ),
    );
  }
}

class PublishedProgrammeCard extends StatelessWidget {
  PublishedProgrammeCard({
    Key? key,
    required this.publishedProgramme,
  }) : super(key: key);

  final SearchPageController controller = Get.find();
  final PublishedProgramme publishedProgramme;
  final double padding = 10;

  @override
  Widget build(BuildContext context) {
    // Va récupérer les programmes de l'utilisateur connecté.
    controller.initMyPrograms();

    final int indexUnderscore = publishedProgramme.numberWeeks != null
        ? publishedProgramme.numberWeeks!.indexOf('_')
        : 0;

    return SizedBox(
      height: 200,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        child: InkWell(
          onTap: () {
            controller.selectProgramme(publishedProgramme);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProgramDetailPage(),
              ),
            );
          },
          child: Stack(
            children: <Widget>[
              (publishedProgramme.imageUrl?.isNotEmpty == true)
                  ? Hero(
                      tag: "${publishedProgramme.uid!}-image",
                      child: Material(
                        child: Ink.image(
                            image: CachedNetworkImageProvider(
                                publishedProgramme.imageUrl!),
                            fit: BoxFit.cover),
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(color: Colors.amber)),
              Column(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.white.withOpacity(0)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Text(
                                      publishedProgramme.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.comfortaa(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  children: <Widget>[
                                    Builder(builder: (context) {
                                      String firstLetter = '';
                                      if (publishedProgramme.creatorName !=
                                          null) {
                                        firstLetter = publishedProgramme
                                            .creatorName!
                                            .substring(0, 1);
                                      }
                                      if (publishedProgramme.creatorPrenom !=
                                          null) {
                                        firstLetter = publishedProgramme
                                            .creatorPrenom!
                                            .substring(0, 1);
                                      }
                                      return (publishedProgramme.creatorImageUrl
                                                  ?.isNotEmpty ==
                                              true)
                                          ? Hero(
                                              tag: publishedProgramme
                                                  .creatorUid!,
                                              child: CircleAvatar(
                                                maxRadius: 15,
                                                minRadius: 5,
                                                foregroundImage:
                                                    CachedNetworkImageProvider(
                                                        publishedProgramme
                                                            .creatorImageUrl!),
                                              ),
                                            )
                                          : CircleAvatar(
                                              maxRadius: 15,
                                              minRadius: 5,
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              child: Text(
                                                firstLetter,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            );
                                    }),
                                    if (publishedProgramme.creatorName !=
                                            null ||
                                        publishedProgramme.creatorPrenom !=
                                            null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          "${publishedProgramme.creatorName} ${publishedProgramme.creatorPrenom}",
                                          style: GoogleFonts.comfortaa(
                                              color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Builder(builder: (context) {
                                  if (publishedProgramme.numberWeeks != null) {
                                    final int numberWeekInt = int.parse(
                                        publishedProgramme.numberWeeks!
                                            .substring(0, indexUnderscore));
                                    return Hero(
                                      tag: "${publishedProgramme.uid}-badge",
                                      child: Badge(
                                        toAnimate: false,
                                        shape: BadgeShape.square,
                                        badgeColor:
                                            Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                        badgeContent: Text(
                                          '$numberWeekInt semaines',
                                          style: GoogleFonts.comfortaa(
                                              color: Colors.white),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListTrainers extends StatelessWidget {
  ListTrainers({Key? key, this.height = 200, this.width = 100})
      : super(key: key);
  final PublishedProgrammeService publishedProgrammeService = Get.find();
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Trainers",
            style: GoogleFonts.comfortaa(fontSize: 22),
          ),
        ),
        SizedBox(
          height: height,
          child: Row(
            children: [
              FutureBuilder<List<Trainers>>(
                  future: publishedProgrammeService
                      .getTrainersWithPublishedProgram(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Erreur : ${snapshot.error.toString()}');
                    }
                    if (snapshot.hasData) {
                      List<Trainers> listTrainers = snapshot.data!;
                      return ListView.builder(
                        itemCount: listTrainers.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, int index) => TrainerCard(
                          trainer: listTrainers.elementAt(index),
                          height: height,
                          width: width,
                        ),
                      );
                    }
                    return Expanded(
                        child: LoadingBouncingGrid.circle(
                      backgroundColor: Theme.of(context).primaryColor,
                    ));
                  }),
            ],
          ),
        ),
      ],
    );
  }
}

class TrainerCard extends StatelessWidget {
  const TrainerCard(
      {Key? key,
      required this.trainer,
      required this.height,
      required this.width})
      : super(key: key);
  final double height;
  final double width;
  final Trainers trainer;

  @override
  Widget build(BuildContext context) {
    Widget imageOrContainer = trainer.imageUrl != null
        ? Image(
            image: CachedNetworkImageProvider(trainer.imageUrl!),
            fit: BoxFit.fitHeight,
            width: double.infinity,
            height: double.infinity,
          )
        : Container(
            color: Theme.of(context).primaryColor,
          );
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: <Widget>[
            imageOrContainer,
            Positioned(
              bottom: 10,
              width: width,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                ),
                child: Text(
                  '${trainer.name} ${trainer.prenom}',
                  style: GoogleFonts.comfortaa(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}