import 'package:badges/badges.dart';
import 'package:fitnc_user/controller/display-type.controller.dart';
import 'package:fitnc_user/page/search/program_detail/program_detail.page.dart';
import 'package:fitnc_user/page/search/search.controller.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';

class SearchPage extends StatelessWidget {
  SearchPage({Key? key}) : super(key: key);
  final SearchPageController controller = Get.put(SearchPageController());
  final DisplayTypeController displayTypeController = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    controller.refreshSearchController();
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        children: <Widget>[
          Text(
            'Explorer',
            style: Theme.of(context).textTheme.headline4,
          ),
          TextFormField(
            onChanged: (String value) => controller.query(value),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
              hintText: 'Recherche...',
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PublishedProgramme>>(
              stream: controller.streamList,
              initialData: const <PublishedProgramme>[],
              builder: (_, AsyncSnapshot<List<PublishedProgramme>> snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("${snapshot.data!.length} résultats"),
                        ],
                      ),
                      Expanded(
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
                                  .map((PublishedProgramme programme) => PublishedProgrammeCard(publishedProgramme: programme))
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
                return LoadingBouncingGrid.circle();
              },
            ),
          ),
        ],
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

    final int indexUnderscore = publishedProgramme.numberWeeks != null ? publishedProgramme.numberWeeks!.indexOf('_') : 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 2,
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
                ? Hero(tag: 'hero_program', child: Ink.image(image: NetworkImage(publishedProgramme.imageUrl!), fit: BoxFit.cover))
                : Container(decoration: const BoxDecoration(color: Colors.amber)),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Text(
                                    publishedProgramme.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cabinCondensed(color: Colors.white, fontSize: 25),
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
                                    return (publishedProgramme.creatorImageUrl?.isNotEmpty == true)
                                        ? CircleAvatar(
                                            maxRadius: 15,
                                            minRadius: 5,
                                            foregroundImage: NetworkImage(publishedProgramme.creatorImageUrl!),
                                          )
                                        : CircleAvatar(
                                            maxRadius: 15,
                                            minRadius: 5,
                                            foregroundColor: Theme.of(context).primaryColor,
                                            child: Builder(builder: (context) {
                                              String firstLetter = '';
                                              if (publishedProgramme.creatorName != null) {
                                                firstLetter = publishedProgramme.creatorName!.substring(0, 0);
                                              }
                                              if (publishedProgramme.creatorPrenom != null) {
                                                firstLetter = publishedProgramme.creatorPrenom!.substring(0, 0);
                                              }
                                              return Text(firstLetter);
                                            }),
                                          );
                                  }),
                                  if (publishedProgramme.creatorName != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        publishedProgramme.creatorName!,
                                        style: GoogleFonts.cabin(color: Colors.white),
                                      ),
                                    ),
                                  if (publishedProgramme.creatorPrenom != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        publishedProgramme.creatorPrenom!,
                                        style: GoogleFonts.cabin(color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Builder(builder: (context) {
                                if (publishedProgramme.numberWeeks != null) {
                                  final int numberWeekInt = int.parse(publishedProgramme.numberWeeks!.substring(0, indexUnderscore));
                                  return Badge(
                                    toAnimate: false,
                                    shape: BadgeShape.square,
                                    badgeColor: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                    badgeContent: Text(
                                      '$numberWeekInt semaines',
                                      style: const TextStyle(color: Colors.white),
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
    );
  }
}
