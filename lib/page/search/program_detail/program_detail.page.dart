import 'package:badges/badges.dart' as badge;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnc_user/page/search/search.controller.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

class ProgramDetailPage extends StatelessWidget {
  const ProgramDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: SearchPageController(),
        builder: (context, child) {
          return Consumer<SearchPageController>(builder: (context, controller, child) {
            return Scaffold(
              floatingActionButton: FutureBuilder<bool>(
                future: controller.isFollowed(),
                initialData: false,
                builder: (context, snapshot) {
                  if (snapshot.hasData && !snapshot.data!) {
                    return FloatingActionButton.extended(
                      elevation: 1,
                      onPressed: () => controller.register(controller.selectedProgramme.value!),
                      label: Text(
                        'follow'.i18n(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              body: SafeArea(
                child: Stack(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500, maxHeight: double.infinity),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 100),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      children: [
                                        Obx(
                                          () => Hero(
                                            tag: "${controller.selectedProgramme.value!.uid!}-image",
                                            child: Image(
                                              image: CachedNetworkImageProvider(
                                                  controller.selectedProgramme.value!.imageUrl!),
                                              fit: BoxFit.fill,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            controller.selectedProgramme.value!.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.comfortaa(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Builder(builder: (context) {
                                          if (controller.selectedProgramme.value!.numberWeeks != null) {
                                            final int indexUnderscore =
                                                controller.selectedProgramme.value!.numberWeeks != null
                                                    ? controller.selectedProgramme.value!.numberWeeks!.indexOf('_')
                                                    : 0;

                                            final int numberWeekInt = int.parse(controller
                                                .selectedProgramme.value!.numberWeeks!
                                                .substring(0, indexUnderscore));
                                            return Hero(
                                              tag: "${controller.selectedProgramme.value!.uid}-badge",
                                              child: badge.Badge(
                                                badgeContent: Text(
                                                  '$numberWeekInt ${'weeks'.i18n()}',
                                                  style: GoogleFonts.comfortaa(color: Colors.white),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        }),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Obx(
                                      () => CreatorWidget(
                                        trainers: controller.trainer.value,
                                        program: controller.selectedProgramme.value,
                                        addToFavorite: (trainer) => controller.addToFavorite(trainer),
                                      ),
                                    ),
                                  ),
                                  if (controller.selectedProgramme.value?.description != null)
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Align(
                                        alignment: AlignmentDirectional.topStart,
                                        child: Text(
                                          controller.selectedProgramme.value!.description!,
                                          style: GoogleFonts.comfortaa(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ]),
              ),
            );
          });
        });
  }
}

class CreatorWidget extends StatelessWidget {
  const CreatorWidget({super.key, required this.trainers, this.addToFavorite, this.program});

  final Trainers trainers;
  final PublishedProgramme? program;
  final void Function(Trainers trainers)? addToFavorite;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: <Widget>[
                  if (trainers.imageUrl != null)
                    Hero(
                      tag: '${trainers.uid!}-${program!.uid}',
                      child: CircleAvatar(
                        foregroundImage: CachedNetworkImageProvider(trainers.imageUrl!),
                      ),
                    ),
                  if (trainers.imageUrl == null)
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'trainer'.i18n(),
                          style: GoogleFonts.comfortaa(fontSize: 12),
                        ),
                        Text(
                          "${trainers.name} ${trainers.prenom}",
                          style: GoogleFonts.comfortaa(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
