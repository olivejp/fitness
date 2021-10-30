import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnc_user/page/exercice/add_exercice.page.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/widget/generic_container.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({Key? key}) : super(key: key);
  final double bottomAppBarHeight = 60;

  @override
  Widget build(BuildContext context) {
    final ExerciceService exerciceService = Get.find();
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            StreamList<Exercice>(
              padding: EdgeInsets.only(
                  bottom: bottomAppBarHeight, top: 8, left: 8, right: 8),
              stream: exerciceService.listenAll(),
              builder: (_, domain) => ExerciceCard(
                exercice: domain,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddExercicePage(
                      exercice: domain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child:
                  ExerciseBottomAppBar(bottomAppBarHeigth: bottomAppBarHeight),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseBottomAppBar extends StatelessWidget {
  const ExerciseBottomAppBar({
    Key? key,
    required this.bottomAppBarHeigth,
  }) : super(key: key);

  final double bottomAppBarHeigth;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).bottomAppBarTheme.color,
      elevation: 10,
      child: SizedBox(
        height: bottomAppBarHeigth,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                label: Text('createExercise'.tr),
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddExercicePage(
                      exercice: Exercice(),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('back'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExerciceCard extends StatelessWidget {
  const ExerciceCard({
    Key? key,
    required this.exercice,
    this.onTap,
  }) : super(key: key);

  final Exercice exercice;
  final GestureTapCallback? onTap;
  final double cardHeight = 80;
  final double imageDimension = 60;
  final double imagePadding = 10;
  final double iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final ExerciceService service = Get.find();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: cardHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: imagePadding, right: imagePadding),
                    child: ExerciseImage(
                        exerciseImageUrl: exercice.imageUrl,
                        dimension: imageDimension),
                  ),
                  Text(exercice.name),
                ],
              ),
              PopupMenuButton<dynamic>(
                iconSize: iconSize,
                tooltip: 'showMore'.tr,
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                itemBuilder: (_) => <PopupMenuEntry<dynamic>>[
                  PopupMenuItem<dynamic>(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('stats'.tr),
                        const Icon(
                          Icons.bar_chart_outlined,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<dynamic>(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('delete'.tr),
                        const Icon(
                          Icons.delete,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    onTap: () => service.delete(exercice),
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

class ExerciseImage extends StatelessWidget {
  const ExerciseImage(
      {Key? key, required this.exerciseImageUrl, this.dimension = 100})
      : super(key: key);
  final String? exerciseImageUrl;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    if (exerciseImageUrl != null) {
      return SizedBox.square(
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Ink.image(
            image: CachedNetworkImageProvider(exerciseImageUrl!),
            fit: BoxFit.cover,
          ),
        ),
        dimension: dimension,
      );
    } else {
      return SizedBox.square(
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(color: Theme.of(context).primaryColor),
        ),
        dimension: dimension,
      );
    }
  }
}
