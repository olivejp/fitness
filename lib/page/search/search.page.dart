import 'package:badges/badges.dart';
import 'package:fitnc_user/controller/display-type.controller.dart';
import 'package:fitnc_user/page/search/search.controller.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:oktoast/oktoast.dart';

class SearchPage extends StatelessWidget {
  SearchPage({Key? key}) : super(key: key);
  final SearchPageController controller = Get.put(SearchPageController());
  final DisplayTypeController displayTypeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
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
              builder: (_, AsyncSnapshot<List<PublishedProgramme>> snapshot) => Obx(
                () => GridView.count(
                  shrinkWrap: true,
                  childAspectRatio: 16 / 9,
                  crossAxisCount: displayTypeController.displayType.value == DisplayType.desktop
                      ? 4
                      : displayTypeController.displayType.value == DisplayType.tablet
                          ? 2
                          : 1,
                  children: snapshot.data!.map((PublishedProgramme programme) => PublishedProgrammeCard(publishedProgramme: programme)).toList(),
                ),
              ),
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
    final int indexUnderscore = publishedProgramme.numberWeeks != null ? publishedProgramme.numberWeeks!.indexOf('_') : 0;
    final int numberWeekInt = int.parse(publishedProgramme.numberWeeks!.substring(0, indexUnderscore));

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 2,
      child: InkWell(
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: (publishedProgramme.imageUrl?.isNotEmpty == true)
                      ? Ink.image(image: NetworkImage(publishedProgramme.imageUrl!), fit: BoxFit.cover)
                      : Container(decoration: const BoxDecoration(color: Colors.amber)),
                ),
                Flexible(
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(publishedProgramme.name),
                      ButtonBar(
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.add_box),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  controller
                                      .register(publishedProgramme)
                                      .then(
                                        (_) => Navigator.of(context).pop(),
                                      )
                                      .catchError((error) {
                                    showToast(
                                      error.toString(),
                                      position: ToastPosition.bottom,
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 5),
                                    );
                                    Navigator.of(context).pop();
                                  });
                                  return Card(
                                    child: LoadingBouncingGrid.circle(),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  )),
                ),
              ],
            ),
            Positioned(
              top: padding,
              left: padding,
              child: (publishedProgramme.creatorImageUrl?.isNotEmpty == true)
                  ? CircleAvatar(
                      foregroundImage: NetworkImage(publishedProgramme.creatorImageUrl!),
                    )
                  : Container(
                      decoration: const BoxDecoration(color: Colors.amber),
                    ),
            ),
            Positioned(
              top: padding,
              right: padding,
              child: (publishedProgramme.numberWeeks != null)
                  ? Badge(
                      toAnimate: false,
                      shape: BadgeShape.square,
                      badgeColor: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      badgeContent: Text(
                        '$numberWeekInt semaines',
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }
}
