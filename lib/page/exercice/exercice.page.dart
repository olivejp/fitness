import 'package:fitnc_user/page/exercice/add_exercice.page.dart';
import 'package:fitnc_user/service/exercice.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/widget/generic_container.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExercicePage extends StatelessWidget {
  const ExercicePage({Key? key}) : super(key: key);
  final double bottomAppBarHeigth = 60;

  @override
  Widget build(BuildContext context) {
    final ExerciceService exerciceService = Get.find();
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            StreamList<Exercice>(
              padding: EdgeInsets.only(bottom: bottomAppBarHeigth, top: 8, left: 8, right: 8),
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
              child: BottomAppBar(
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
                          label: Text('Créer un exercice'),
                          icon: Icon(Icons.add_circle_outline_rounded),
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
                          child: Text('Retour'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    final ExerciceService service = Get.find();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: ExerciceImage(exerciceImageUrl: exercice.imageUrl, dimension: 60),
                  ),
                  Text(exercice.name),
                ],
              ),
              PopupMenuButton<dynamic>(
                iconSize: 24,
                tooltip: 'Voir plus',
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                itemBuilder: (_) => <PopupMenuEntry<dynamic>>[
                  PopupMenuItem<dynamic>(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const <Widget>[
                        Text('Stats'),
                        Icon(
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
                      children: const <Widget>[
                        Text('Supprimer'),
                        Icon(
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

class ExerciceImage extends StatelessWidget {
  const ExerciceImage({Key? key, required this.exerciceImageUrl, this.dimension = 100}) : super(key: key);
  final String? exerciceImageUrl;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    if (exerciceImageUrl != null) {
      return SizedBox.square(
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Ink.image(
            image: NetworkImage(exerciceImageUrl!),
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
